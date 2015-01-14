#!/bin/sh
echo "
\documentclass{standalone}
\usepackage[utf8]{inputenc}
\usepackage{pgfplots}" > Freq.tex

echo "
\pgfplotstableread[row sep=crcr]{ " > TempTable.tex    

echo "" > TempNode.tex 

for FRKM in 2.61e3 9.73e3 1.77e4 2.40e4 3.02e4 3.64e4 4.26e4 4.85e4 5.43e4 5.99e4

do
	echo "1	$FRKM	\\\\\\" >>TempTable.tex
	echo "
%\\\draw [blue,line width=1pt] ( axis cs:1, $FRKM) -- ( axis cs:1.1, $FRKM);
\\\node [anchor=east,right,color=blue!60!black,font=\\\tiny] at (axis cs:1, $FRKM) {$FRKM};" >> TempNode.tex
done


echo "}\FRKM
\pgfplotstableread[row sep=crcr]{ " >> TempTable.tex 

for FPOD in 3.00e3 4.06e3 3.92e3 1.27e4 1.74e4 2.24e4 2.74e4 3.27e4 3.80e4 4.39e4
do
	echo "1	$FPOD	\\\\\\" >> TempTable.tex
	echo "
%\\\draw [red,line width=1pt] ( axis cs:1, $FPOD) -- ( axis cs: 0.9, $FPOD);
\\\node [anchor=east,left,color=red!60!black,font=\\\tiny] at (axis cs:1, $FPOD) {$FPOD};" >> TempNode.tex
done


echo "}\FPOD " >> TempTable.tex

cat TempTable.tex >> Freq.tex

echo '
\\begin{document}
\\begin{tikzpicture}
\\begin{axis}[
    x=1.7cm,            % x unit vector
    xmin=0.2,xmax=1.8,
    hide x axis,        % hide the x axis
    ymode = log,        % logarithmic x axis
    y=1.7cm,
    axis y line*=left,% only show the bottom y axis line, without an arrow tip
    ymin=2e3, ymax=7e4,% range for the x axis
    ylabel = Frequence en $s^{-1}$
]
\\addplot [only marks, mark size=2.5, mark=square*, fill=blue , draw=blue] table {\FRKM};
\\addplot [only marks, mark=square*, fill=red , draw=red] table {\FPOD};
' >> Freq.tex

cat TempNode.tex >> Freq.tex

echo "
\\\end{axis}
\\\end{tikzpicture}

\\\end{document}" >> Freq.tex

rm TempTable.tex TempNode.tex

pdflatex -shell-escape Freq.tex >> /dev/null