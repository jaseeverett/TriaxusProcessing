function out = Triaxus_ObliqueVol(out)

sm_time = 30; % secs
[~,idx] = unique(out.datenum,'legacy');

out.d_depth = [NaN; abs(diff(out.CTD.Depth))];
out.d_depth(1) = nanmean(out.d_depth);

[out.d_grnddist, out.grnddist] = MissLink_grnddist(out.GPS.Lat,out.GPS.Lon,out.datenum,'m');



%% Now do oblique distance and volume.
Dist = sqrt(out.d_grnddist(idx).^2 + out.d_depth(idx).^2);
Velocity = Dist(2:end) ./ diff(out.secs(idx)); % m s-1
Velocity = [Velocity; nanmean(Velocity(end-10:end))]; % Take the average of the last 10 obs

out.Flow.Oblique.Dist = Dist(dsearchn(out.datenum(idx),out.datenum));
out.Flow.Oblique.Velocity = Velocity(dsearchn(out.datenum(idx),out.datenum));
    
    Vol = out.Flow.Oblique.Dist.*out.SA;
    out.Flow.Olique.Vol = MissLink_Filter(Vol,out.datenum,sm_time);
    out.Flow.Oblique.Vol = Vol(dsearchn(out.datenum(idx),out.datenum));
    
    out.Flow.Dist = out.Flow.Oblique.Dist;
    out.Flow.Velocity = out.Flow.Oblique.Velocity;
    out.Flow.Vol = out.Flow.Oblique.Vol;
    
    %     out.Flow.Vol = [nanmean(out.Flow.Vol); out.Flow.Vol];
    out.Flow.TotalVol = nansum(out.Flow.Vol);
    out.Flow.FlowUsed = 'ObliqueDistance';