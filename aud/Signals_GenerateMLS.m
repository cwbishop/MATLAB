function Y=Signals_GenerateMLS(M)
%
% Signals_GenerateMLS  --  Genrate a MLS signal.
% 
% function Y=Signals_GenerateMLS(M)
%
% Input:
%   M:		The order of the sequence.
%
% Output:
%   Y:		The signal vector.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                               
%                                                                               
%                         Hearing Research and Technology                       
%                               Starkey Labs, Inc.                              
%                                                                               
%                                @CopyRight 2005                                
%                              All Rights Reserved                              
%                                                                               
%                                                                               
% Author: Tao Zhang                                                             
%                                                                               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (M>24) | (M<2)
	Error('M must be between 2 and 24!');
end

TapBits=cell(24, 1);
TapBits(2)={[1 2]};
TapBits(3)={[2 3]};
TapBits(4)={[3 4]};
TapBits(5)={[4 5]};
TapBits(6)={[5 6]};
TapBits(7)={[6 7]};
TapBits(8)={[2 3 5 8]};
TapBits(9)={[5 9]};
TapBits(10)={[7 10]};
TapBits(11)={[9 11]};
TapBits(12)={[6 8 11 12]};
TapBits(13)={[9 10 12 13]};
TapBits(14)={[4 8 13 14]};
TapBits(15)={[14 15]};
TapBits(16)={[4 13 15 16]};
TapBits(17)={[14 17]};
TapBits(18)={[11 18]};
TapBits(19)={[14 17 18 19]};
TapBits(20)={[17 20]};
TapBits(21)={[19 21]};
TapBits(22)={[21 22]};
TapBits(23)={[18 23]};
TapBits(24)={[17 22 23 24]};

TappedBits=TapBits{M};
TappedBits=reshape(TappedBits, length(TappedBits), 1);

X=2^M-1;
for i=1:2^M-1
	Y(i)=Bit_GetBit(X, TappedBits(1));
	for j=2:length(TappedBits)
		Y(i)=bitxor(Bit_GetBit(X, TappedBits(j)), Y(i));
	end
	X=Bit_ShiftLeft(X, 1, M)+Y(i);
end

Index=find(Y==0);
Y(Index)=-1;
return;

%===============================================================================
%
% Bit_GetBit	--	Return the result of the ith bit.
%
% function b=Bit_GetBit(a, i, NumberBits)
%
% Input:
%	a:	The input number.
%	i:	1 to number of bits
%	NumberBits:
%
% Output:
%	b:	The ith bit.
%
% Warning:
%	'BitGet" dose not work because of a bug at 32 bit.
%
%===============================================================================
function b=Bit_GetBit(a, i, NumberBits)

if nargin<3
	NumberBits=16;
end

if a<0
	a=2^NumberBits+a;
    b=bitget(a, i);
else
    y=2^(i-1);
    if bitand(a, y)
       b=1;
    else
       b=0;
    end
end


return;

%===============================================================================
%
% Bit_ShiftLeft	--	Shift the variable 'NumberBits' to the left. 
%
% function b=Bit_ShiftLeft(a, NumberBits, WordLength)
%
% Input:
%	a:			The input number.
%	NumberBits:	Number of bits to shift.
%	WordLength:	Word length.
%
% Output:
%	b:	The shifted number.
%
%===============================================================================
function b=Bit_ShiftLeft(a, NumberBits, WordLength)

if a<0
   disp('A must be nonnegative!');
   return;
end

for i=1:NumberBits
   a=a*2;
end
b=bitand(a, 2^WordLength-1);
return;

