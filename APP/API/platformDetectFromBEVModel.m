function detect = platformDetectFromBEVModel(app, rootFolder)
    % Detect a  platform by scanning Subsystem Reference blocks and
    % comparing the REFERENCED MODEL (.slx basename) to the platform list.
    detect = false;

    try
        % Candidate platforms from dropdown (normalize: strip .slx, trim, lower)
        vehPlatformItemsRaw = string(app.VehicleTemplateDropDown.Items);
        if isempty(vehPlatformItemsRaw), return; end
        vehPlatformBases = erase(vehPlatformItemsRaw,".slx");

        % Resolve BEV model file from dropdown
        bevDropdownVal  = char(app.BEVModelDropDown.Value);             % 'BEV_Top.slx' or 'BEV_Top'
        bevModelName = regexprep(bevDropdownVal, '\.slx$', '', 'ignorecase'); % strip .slx
        bevFile = '';

        try
            hit = dir(fullfile(char(rootFolder), '**', [bevModelName '.slx']));
            if ~isempty(hit)
                bevFile = fullfile(hit(1).folder, hit(1).name);
            else
                w = which(bevModelName);
                if ~isempty(w), bevFile = w; end
            end
        catch
        end

        if isempty(bevFile) || ~exist(bevFile,'file')
            try
                uialert(app.UIFigure, ...
                    "The selected BEV model file could not be located on disk.", ...
                    "BEV Model Not Found", 'Icon','error');
            catch
            end
            return
        end

        % Load model if needed
        modelOpened = false;
        [~, mdlNameOnly] = fileparts(bevFile);
        if ~bdIsLoaded(mdlNameOnly)
            load_system(bevFile);
            modelOpened = true;
        end

        % FAST scan: only SSRs with ReferencedSubsystem set
        baseOpts = { ...
    'LookUnderMasks','none', ...
    'FollowLinks','off', ...
    'IncludeCommented','off', ...
    'Regexp','on', ...
    'MatchFilter',@Simulink.match.activeVariants ...   % 
            };

        ssrPaths = find_system(mdlNameOnly, baseOpts{:}, ...
                               'BlockType','SubSystem','ReferencedSubsystem','.+');

        % Fallback: heavy scan if nothing found
        if isempty(ssrPaths)
            heavyOpts = {'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on', ...
                         'MatchFilter', @Simulink.match.allVariants,'Regexp','on'};
            ssrPaths = find_system(mdlNameOnly, heavyOpts{:}, ...
                                   'BlockType','SubSystem','ReferencedSubsystem','.+');
        end

        if isempty(ssrPaths)
            try
                uialert(app.UIFigure, ...
                    "No Subsystem Reference (with a referenced model) found in the selected BEV model. " + ...
                    "Component creation will be aborted.", ...
                    "Vehicle Platform Missing", 'Icon','error');
            catch
            end
            if modelOpened, try, close_system(mdlNameOnly, 0); catch, end, end
            return
        end

        % Extract referenced model basenames from SSRs
        refStrings = get_param(ssrPaths, 'ReferencedSubsystem');
        if ischar(refStrings), refStrings = {refStrings}; end
        refBases = strings(0,1);
        for ii = 1:numel(refStrings)
            refBases(end+1,1) = string(refStrings{ii}); %#ok<AGROW>
        end
        refBases = unique(refBases(refBases ~= ""), 'stable');

        % Compare to candidate platform basenames (first match wins)
        matchIdx = [];
        for p = 1:numel(vehPlatformBases)
            if any(strcmpi(vehPlatformBases(p), refBases))
                matchIdx = p; break;
            end
        end

        if ~isempty(matchIdx)
            %appH.VehicleTemplateDropDown.Value = char(platformItemsRaw(matchIdx));
            detect = true;
        else
            try
                uialert(app.UIFigure, ...
                    "No Vehicle Platform referenced model matched the available platform list. " + ...
                    "Component creation will be aborted.", ...
                    "Vehicle Platform Not Detected", 'Icon','error');
            catch
            end
        end

        
        if modelOpened
            try, close_system(mdlNameOnly, 0); catch, end
        end
    catch
        % swallow and return false
    end
end
