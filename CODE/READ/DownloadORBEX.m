function [settings] = DownloadORBEX(settings, gpsweek, dow, yyyy, mm, doy)
% This function dowloads the ORBEX file from IGS or Analysis Center server.
%
% INPUT:
%	settings        struct, settings from GUI
%   gpsweek         string, GPS Week
%   dow             string, 1-digit, day of week
%   yyyy            string, 4-digit, year
%   mm              string, 2-digit, month
%   doy             string, 3-digit, day of year
% OUTPUT:
%	settings        updated
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************



%% Preparations
target = {[Path.DATA, 'ORBIT/', yyyy, '/', doy '/']};
[~, ~] = mkdir(target{1});
URL_host = 'igs.ign.fr:21';            % default ftp-server
decompressed = {''};
URL_host_2 = ''; URL_folder_2 = ''; file_2 = '';
file_status = 0;

%% switch source of orbits/clocks
if settings.ORBCLK.MGEX
    % http://www.igs.org/products
    URL_folder = {['/pub/igs/products/mgex/', gpsweek, '/']};
    switch settings.ORBCLK.prec_prod
        case 'IGS'
            URL_host = 'https://cddis.nasa.gov';
            URL_folders = {['/archive/gnss/products/' gpsweek '/']};
            files = {['IGS0DEMFIN_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            % download
            file_status = get_cddis_data(URL_host, URL_folders, files, target, true);
            if file_status == 0
                errordlg('No IGS MGEX ORBEX found on server. Please specify different source!', 'Error');
            end
            % decompress
            decompressed = unzip_and_delete(files, target);
            % save filepath
            settings.ORBCLK.file_obx = decompressed{1};
            return
            
        case 'CODE'
            host = 'http://www.aiub.unibe.ch/download/';
            URL_folder = {['/CODE_MGEX/CODE/' yyyy, '/']};
            file = {['COD0MGXFIN_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            decomp = {['COD0MGXFIN_' yyyy doy '0000_01D_30S_ATT.OBX']};
            % download
            if ~isfile([target{1} file{1}]) && ~isfile([target{1} decomp{1}]) && ~isfile([target{1} decomp{1} '.mat']) 
                try
                    websave([target{1} file{1}], [host URL_folder{1} file{1}]);
                    file_status = 1;
                catch
                end
            end

        case 'CNES'
            file = {['GRG0MGXFIN_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            
        case 'WUM'
            switch settings.ORBCLK.prec_prod_type
                case 'Rapid'
                    URL_host = 'igs.gnsswhu.cn:21';
                    URL_folder = {['/pub/whu/phasebias/' yyyy, '/orbit/']};
                    file = {['WUM0MGXRAP_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
                case 'Final'
                    URL_folder = {['/pub/igs/products/mgex/', gpsweek, '/']};
                    file = {['WUM0MGXFIN_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            end

            % try ftps://bdspride.com
            URL_host_1 = 'ftps://bdspride.com/';
            URL_folders_1 = ['wum/' gpsweek '/'];
            file_status = CurlDownload([target{1} file{1}], [URL_host_1 URL_folders_1 file{1}], false);

            
        case 'GFZ'
            file = {['GBM0MGXRAP_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            URL_host = 'ftp.gfz-potsdam.de:21';
            if str2double(gpsweek) > 2245
                URL_folder = {['/pub/GNSS/products/mgex/' gpsweek '_IGS20' '/']};
            else
                URL_folder = {['/pub/GNSS/products/mgex/' gpsweek '/']};
            end
            % alternative
            URL_host_2   = 'igs.ign.fr:21';
            URL_folder_2 = {['/pub/igs/products/mgex/', gpsweek, '/']};
            file_2   = {['GFZ0MGXRAP_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            
        case 'HUST'
            URL_host = 'ggda.ac.cn:21';
            URL_folder = {['/pub/mgex/products/' yyyy '/']};
            switch settings.ORBCLK.prec_prod_type
                case 'Final'
                    file = {['HUS0MGXFIN_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
                case 'Rapid'
                    file = {['HUS0MGXRAP_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
                case 'Ultra-Rapid'
                    file = {['HUS0MGXULT_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            end

        case 'WCC'
            file = {['WCC0OPSFIN_' yyyy doy '0000_01D_30S_ATT.OBX.gz']};
            % try ftps://bdspride.com
            URL_host_1 = 'ftps://bdspride.com/';
            URL_folders_1 = ['wcc/' gpsweek '/'];
            file_status = CurlDownload([target{1} file{1}], [URL_host_1 URL_folders_1 file{1}], false);

        otherwise
            errordlg('No ORBEX file for this institution', 'ORBEX Error');
            return
            
    end
    
else
            errordlg('ORBEX file for non-MGEX products are not implemented!', 'ORBEX Error');
            return
end

% ||| add more


%% download and unzip files, if necessary
if file_status == 0
    file_status = ftp_download(URL_host, URL_folder{1}, file{1}, target{1}, true);
end
if file_status == 0 && ~isempty(URL_host_2)
    % download failed, try another ftp server
    file_status = ftp_download(URL_host_2, URL_folder_2{1}, file_2{1}, target{1}, true);
end
decompressed = unzip_and_delete(file(1), target(1));
if file_status == 0
    errordlg(['No ORBEX file from ' settings.ORBCLK.prec_prod ' found on server. Disable ORBEX file!'], 'Error');
    return
end

%% save file-path into settings
settings.ORBCLK.file_obx = decompressed{1};	


