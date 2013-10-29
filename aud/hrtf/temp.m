for loc=1:5
    wavplay(int_test(:,:,loc),fs),pause(.3)
    wavplay(ext_test(:,:,loc),fs),pause(.3)
end