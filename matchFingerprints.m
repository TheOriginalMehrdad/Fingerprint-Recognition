function [bestIndex, bestScore, bestMatchCount, bestGlobalScore, secondBestScore] = ...
    matchFingerprints(queryMinutiae, queryEnh, fingerDB, distanceThreshold, orientationThreshold)
% matchFingerprints
%   Combined global (SSIM) + local (minutiae) matching.
%   Returns:
%       bestIndex        - index of best matching entry in DB
%       bestScore        - local similarity score (minutiae)
%       bestMatchCount   - number of matched minutiae
%       bestGlobalScore  - global similarity (SSIM) of best entry
%       secondBestScore  - second best local score (for ambiguity check)

    if isempty(queryMinutiae)
        warning('Query minutiae set is empty.');
        bestIndex        = -1;
        bestScore        = 0;
        bestMatchCount   = 0;
        bestGlobalScore  = 0;
        secondBestScore  = 0;
        return;
    end

    numEntries = numel(fingerDB);
    localScores   = zeros(1, numEntries);
    matchCounts   = zeros(1, numEntries);
    globalScores  = zeros(1, numEntries);

    for k = 1:numEntries
        dbMinutiae = fingerDB(k).minutiae;
        dbEnh      = fingerDB(k).enhanced;

        [localScores(k), matchCounts(k)] = ...
            computeMatchScore(queryMinutiae, dbMinutiae, distanceThreshold, orientationThreshold);

        % Global similarity using SSIM (optional)
        try
            globalScores(k) = ssim(queryEnh, dbEnh);
        catch
            globalScores(k) = 0;
        end
    end

    % Sort by local score
    [sortedScores, sortedIdx] = sort(localScores, 'descend');

    bestScore       = sortedScores(1);
    bestIndex       = sortedIdx(1);
    bestMatchCount  = matchCounts(bestIndex);
    bestGlobalScore = globalScores(bestIndex);

    if numEntries >= 2
        secondBestScore = sortedScores(2);
    else
        secondBestScore = 0;
    end
end

function [score, matches] = computeMatchScore(queryMinutiae, dbMinutiae, distanceThreshold, orientationThreshold)
% computeMatchScore
%   Computes similarity score between two sets of minutiae using
%   nearest-neighbor matching with distance + orientation constraints.

    if isempty(queryMinutiae) || isempty(dbMinutiae)
        score   = 0;
        matches = 0;
        return;
    end

    if numel(queryMinutiae) < 5 || numel(dbMinutiae) < 5
        score   = 0;
        matches = 0;
        return;
    end

    usedDb = false(1, numel(dbMinutiae));
    matches = 0;

    for i = 1:numel(queryMinutiae)
        qi = queryMinutiae(i);

        bestDist = Inf;
        bestIdx  = -1;

        for j = 1:numel(dbMinutiae)
            if usedDb(j)
                continue;
            end
            if ~strcmp(qi.type, dbMinutiae(j).type)
                continue;
            end

            % Orientation consistency
            if isfield(qi, 'theta') && isfield(dbMinutiae(j), 'theta')
                dTheta = angularDiffDeg(qi.theta, dbMinutiae(j).theta);
                if dTheta > orientationThreshold
                    continue;
                end
            end

            d = hypot(qi.x - dbMinutiae(j).x, qi.y - dbMinutiae(j).y);
            if d < bestDist
                bestDist = d;
                bestIdx  = j;
            end
        end

        if bestIdx ~= -1 && bestDist <= distanceThreshold
            matches         = matches + 1;
            usedDb(bestIdx) = true;
        end
    end

    nQuery = numel(queryMinutiae);
    nDb    = numel(dbMinutiae);
    score  = matches / max(nQuery, nDb);
end

function d = angularDiffDeg(a, b)
% angularDiffDeg
%   Minimal absolute difference between two angles in degrees (mod 180).

    diff = abs(a - b);
    d = min(diff, 180 - diff);
end
