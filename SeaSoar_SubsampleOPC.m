function ss = SS_SubsampleOPC(s)

avg = 2; % Even Number - No of seconds to average for

% avg = 20; % Even Number - No of seconds to average for
% disp(' ')
% warning('Avergaing to 20s - not for database')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% NOW AVERAGE FOR EVERY 'avg' SECONDS AND RESAVE %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic

ss.location = s.location;
ss.instrument = s.instrument;
ss.analyst = s.analyst;
ss.created = datestr(now);
ss.filename = [s.filename(1:end-8),'_Avg.mat'];
ss.start = datestr(s.datenum(1));
ss.finish = datestr(s.datenum(end));
ss.totDist = [];
ss.OPCfiles = s.OPCfiles;
ss.SampleInterval = ([num2str(avg),' secs']);
ss.MinESD = s.MinESD;
ss.MaxESD = s.MaxESD;

k = 0;

disp('Start taking averages')

for j = (avg/2):avg:(ceil(s.secs(end))-avg/2)
    
    fi = find(s.secs>j-avg/2 & s.secs<=j+avg/2);
    
     if ~isempty(fi)
        k = k + 1;
        
        m = round(mean(fi));
        ss.datenum(k,1) = s.datenum(m,1);
        ss.secs(k,1) = j;
        
        ss.intTime(k,1) = s.secs(fi(end),1) - s.secs(fi(1),1);
        ss.intDist(k,1) = s.distance(fi(end),1)-s.distance(fi(1),1);
        ss.intPts(k,1) = length(fi);
        
        ss.latitude(k,1) = mean(s.latitude(fi,1));
        ss.longitude(k,1) = mean(s.longitude(fi,1));
        ss.pressure(k,1) =  mean(s.pressure(fi,1));
        ss.Depth(k,1) = mean(s.Depth(fi,1));
        ss.temperature(k,1) = mean(s.temperature(fi,1));
        ss.salinity(k,1) =  mean(s.salinity(fi,1));
        ss.sigmaT(k,1) = mean(s.sigmaT(fi,1)); % kg m-3
        
        if year(s.datenum(1)) ~= 2004
            ss.fluorescence(k,1) = mean(s.fluorescence(fi,1));
        end
        
%         ss.oxygen(k,1) =  mean(s.oxygen(fi,1));
        ss.distance(k,1) = s.distance(m,1);
        ss.grnddist(k,1) = s.grnddist(m,1); % km
        
        ss.velocity(k,1) = nanmean(s.velocity(fi,1));
        %             ss.velocity(k,1) = ss.intDist(k,1)/ss.intTime(k,1); %m s-1
        ss.flow(k,1) = ss.velocity(k,1).*s.OPC_SA;
        
        if length(fi) == 1
            ss.intTime(k,1) = avg;
        end
        
        ss.vol(k,1) = ss.flow(k,1)*ss.intTime(k,1);
       
        if isinf(ss.vol(k))==1 % | ss.vol(k) < 0.005
            disp('stop here')
        end
        
        
        opc.NBSS.min_count = 1;
        opc.MinESD = s.MinESD;
        opc.MaxESD  = s.MaxESD;
        opc.Unit = 'OPC2T';
        opc.DigiTime = s.secs(fi);
        %         opc.Flow = s.velocity(fi);
        opc.flow_mark = 1;
        
        opc.Flow.TotalVol = ss.vol(k,1);
        %
        
        if year(s.datenum(1))== 2004
            % Unwrap Binned ESD
            opc.ESD = [];
            for ix = 1:length(fi)
                opc.ESD = [opc.ESD; s.ESD{fi(ix),:}];
            end
            clear ix
            
        else
            opc.ESD = s.ESD(fi);            
        end
        
        ss.ESD{k,1} = opc.ESD;
        ss.ESD_count(k,1) = length(opc.ESD);
        
        opc = OPC_Parameters(opc);
        opc = OPC_Pareto(opc);
        opc = OPC_Bin(opc);
        opc = OPC_NBSS(opc);
%         opc = OPC_BioVol(opc);
        
        if k == 1
            ss.Bins_ESD = opc.NBSS.all.Bins_ESD;
            ss.Limits_ESD = opc.NBSS.all.Limits_ESD;
        end
        
        ss.Binned_ESD(k,:) = opc.NBSS.all.Histo;
              
%         if sum(opc.NBSS.all.Histo) ~= length(opc.ESD)
%             error('Length of ESD')
%         end
        
        
        if isfield(opc.NBSS,'Lin') == 1
            if isfield(opc.NBSS.Lin,'Slope') == 1
                ss.NBSS_Slope(k,1) = opc.NBSS.Lin.Slope;
                ss.NBSS_Intercept(k,1) = opc.NBSS.Lin.Intercept;
            else
                ss.NBSS_Slope(k,1) = NaN;
                ss.NBSS_Intercept(k,1) = NaN;
            end
        else
            ss.NBSS_Slope(k,1) = NaN;
            ss.NBSS_Intercept(k,1) = NaN;
        end
        
        ss.pareto(k,1) = opc.Pareto.Slope;
        ss.bugVOL(k,1) = opc.Stats.BioVol; %m3 m-3
        ss.biomass(k,1) = opc.Stats.Biomass;
        ss.counts(k,1) = opc.Stats.Total_Counts;
        ss.abundance(k,1) = opc.Stats.Abundance;
        ss.GeoMnESD(k,1) = opc.Stats.GeoMn;
                
        clear opc
    end
end

toc