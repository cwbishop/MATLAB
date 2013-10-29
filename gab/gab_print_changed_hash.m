function gab_print_changed_hash(job)

tasks=[job.task{:}];
funcHashes=[tasks.funcHashes];
first=true;

for f=1:length(funcHashes)
    [~,outp]=unix(['md5sum ' which(funcHashes(f).funcName)]);
    x=textscan(outp,'%s%s');
    if ~strcmp(x{1}{1},funcHashes(f).md5) %if they don't match
        if first
            first=false;
            fprintf(1,'New\t\tOld\t\tFile\n');
        end
        fprintf(1,'%s\t%s\t%s\n',x{1}{1},funcHashes(f).md5,x{2}{1});
    end
end