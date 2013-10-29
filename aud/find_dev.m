function [dev_num] = find_dev(dev_name)
%%%%[device_num] = find_dev(dev_name)
%%%%ie find_dev('Gina3G 7-8 Digital In')
daqinfo = daqhwinfo('winsound');
board_char = char(daqinfo.BoardNames);
dev_num = strmatch(dev_name, board_char,'exact') -1;