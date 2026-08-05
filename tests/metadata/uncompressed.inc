% Shared by every fixture in this suite.
%
% The default build path compresses the catalog into an object stream, where a
% text search of the file cannot see it -- the false negative that produced the
% #276 report. Turning compression off is what makes the assertion in run.sh a
% statement about the PDF rather than about zlib. \relax terminates the number
% so TeX does not scan the following control sequence looking for more digits.
\pdfvariable compresslevel=0\relax
\pdfvariable objcompresslevel=0\relax
