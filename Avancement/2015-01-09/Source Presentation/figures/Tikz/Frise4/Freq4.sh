#!/bin/sh
echo "
\documentclass{standalone}
\usepackage[utf8]{inputenc}
\usepackage{pgfplots}" > Freq.tex

echo "
\pgfplotstableread[row sep=crcr]{ " > TempTable.tex    

echo "" > TempNode.tex 

for FRKM in 0.27e4 0.93e4 2.35e4 1.38e4 1.98e4 2.96e4 4.30e4 4.90e4 5.45e4 5.99e4 #0.27e4 0.84e4 2.50e4 1.48e4 2.61e4 2.07e4 4.24e4 4.86e4 5.39e4 5.92e4

do
	echo "1	$FRKM	\\\\\\" >>TempTable.tex
	echo "
%\\\draw [blue,line width=1pt] ( axis cs:1, $FRKM) -- ( axis cs:1.1, $FRKM);
\\\node [anchor=east,right,color=blue!60!black,font=\\\tiny] at (axis cs:1, $FRKM) {$FRKM};" >> TempNode.tex
done


echo "}\FRKM
\pgfplotstableread[row sep=crcr]{ " >> TempTable.tex 

for FPOD in  0.26e4 0.36e4 2.50e4 1.16e4 1.96e4 2.27e4 2.70e4 3.22e4 3.85e4 4.35e4 5.00e4 5.26e4 5.88e4 #0.26e4 0.36e4 2.50e4 1.19e4 2.50e4 2.08e4 2.50e4 2.78e4 3.57e4 4.17e4 5.00e4 4.17e4 5.00e4 5.00e4 6.25e4
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