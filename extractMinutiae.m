function minutiae = extractMinutiae(skeletonImg)
% extractMinutiae
%   Extract ridge endings and bifurcations from a skeletonized fingerprint.
%   Each minutia has fields:
%       x, y    - pixel coordinates
%       type    - 'ending' or 'bifurcation'
%       theta   - local ridge orientation in degrees [0, 180)

    skeletonImg = logical(skeletonImg);

    % Find endpoints and branchpoints
    endpoints   = bwmorph(skeletonImg, 'endpoints');
    branchpoints = bwmorph(skeletonImg, 'branchpoints');

    [yE, xE] = find(endpoints);
    [yB, xB] = find(branchpoints);

    % All skeleton pixels for orientation estimation
    [ys, xs] = find(skeletonImg);
    skelPoints = [xs, ys];

    minutiae = struct('x', {}, 'y', {}, 'type', {}, 'theta', {});
    idx = 1;

    % Process ridge endings
    for k = 1:numel(xE)
        cx = xE(k);
        cy = yE(k);
        [thetaDeg, ok] = localOrientation([cx, cy], skelPoints);
        if ~ok
            continue;
        end
        minutiae(idx).x     = cx;
        minutiae(idx).y     = cy;
        minutiae(idx).type  = 'ending';
        minutiae(idx).theta = thetaDeg;
        idx = idx + 1;
    end

    % Process bifurcations
    for k = 1:numel(xB)
        cx = xB(k);
        cy = yB(k);
        [thetaDeg, ok] = localOrientation([cx, cy], skelPoints);
        if ~ok
            continue;
        end
        minutiae(idx).x     = cx;
        minutiae(idx).y     = cy;
        minutiae(idx).type  = 'bifurcation';
        minutiae(idx).theta = thetaDeg;
        idx = idx + 1;
    end
end

function [thetaDeg, ok] = localOrientation(p, skelPoints)
% localOrientation
%   Estimate local ridge orientation at point p = [x, y]
%   using nearby skeleton pixels within a fixed radius.

    radius = 10; % pixels
    dx = skelPoints(:,1) - p(1);
    dy = skelPoints(:,2) - p(2);
    d2 = dx.^2 + dy.^2;

    mask = d2 > 0 & d2 <= radius^2;
    if nnz(mask) < 5
        ok = false;
        thetaDeg = 0;
        return;
    end

    mx = mean(skelPoints(mask,1));
    my = mean(skelPoints(mask,2));

    vx = mx - p(1);
    vy = my - p(2);

    % Image coordinates: y grows downward, so invert vy
    thetaRad = atan2(-vy, vx);
    thetaDeg = mod(rad2deg(thetaRad), 180); % ridge direction is 180-periodic
    ok = true;
end
