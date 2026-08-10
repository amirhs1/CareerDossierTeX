% Shared by every fixture in this suite.
%
% Link annotations are ordinary PDF objects, and on the default build path they
% are packed into an object stream where a text search of the file cannot see
% them -- which is why issue #328 had to be reported from a hand-decompressed
% file rather than from `grep' on build/examples/resume-english.pdf. Turning
% compression off is what makes the assertions in run.sh statements about the
% emitted annotations rather than about zlib. \relax terminates the number so
% TeX does not scan the following control sequence looking for more digits.
\pdfvariable compresslevel=0\relax
\pdfvariable objcompresslevel=0\relax
