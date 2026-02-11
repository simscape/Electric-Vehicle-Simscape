function detect = controlsDetectFromBEVModel(app, rootFolder)
    % Detect a  platform by scanning Subsystem Reference blocks and
    % comparing the REFERENCED MODEL (.slx basename) to the platform list.
    detect = false;
    controlFolder = fullfile(rootFolder, 'Components\Controller\Model');
    app.ControlSelectionDropDown.Items = getSLXFiles(controlFolder);


    try
        % Candidate platforms from dropdown (normalize: strip .slx, trim, lower)
        controlsItemsRaw = string(app.ControlSelectionDropDown.Items);
        if isempty(controlsItemsRaw), return; end
        controlBases = erase(controlsItemsRaw,".slx");

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

        % % Fallback: heavy scan if nothing found
        % if isempty(ssrPaths)
        %     heavyOpts = {'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on', ...
        %                  'MatchFilter', @Simulink.match.allVariants,'Regexp','on'};
        %     ssrPaths = find_system(mdlNameOnly, heavyOpts{:}, ...
        %                            'BlockType','SubSystem','ReferencedSubsystem','.+');
        % end

        % if isempty(ssrPaths)
        %     try
        %         uialert(app.UIFigure, ...
        %             "No Subsystem Reference (with a referenced model) found in the selected BEV model. " + ...
        %             "Component creation will be aborted.", ...
        %             "Vehicle Platform Missing", 'Icon','error');
        %     catch
        %     end
        %     if modelOpened, try, close_system(mdlNameOnly, 0); catch, end, end
        %     return
        % end

        % Extract referenced model basenames from SSRs
        refStrings = get_param(ssrPaths, 'ReferencedSubsystem');
        if ischar(refStrings), refStrings = {refStrings}; end
        refBases = strings(0,1);
        for ii = 1:numel(refStrings)
            refBases(end+1,1) = extractRefModelBase(string(refStrings{ii})); %#ok<AGROW>
        end
        refBases = unique(refBases(refBases ~= ""), 'stable');

        % Compare to candidate platform basenames (first match wins)
        matchIdx = [];
        for p = 1:numel(controlBases)
            if any(strcmpi(controlBases(p), refBases))
                matchIdx = p; break;
            end
        end

        if ~isempty(matchIdx)
            detect = true;
        else
            try
                uialert(app.UIFigure, ...
                    "No Controller referenced model matched the available platform list. " + ...
                    "control selection will be aborted.", ...
                    "Controller Not Detected", 'Icon','error');
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
