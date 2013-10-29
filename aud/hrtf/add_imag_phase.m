function fullPH=add_imag_phase(realPH)
%reconstructs a full phase of both real and imaginary components given just
%the real component. It accomplishes this by flipping the real phase in
%both the x and y dimensions. It works on each collum of the input

for i=1:size(realPH,2)
    imagPH=-flipud(realPH(:,i));
    fullPH(:,i)=[realPH(:,i);imagPH-(diff([realPH(end,i),imagPH(1)])+diff([realPH(end,i),realPH(end-1,i)]))];
end