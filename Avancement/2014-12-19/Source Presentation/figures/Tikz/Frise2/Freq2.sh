#!/bin/sh
echo "
\documentclass{standalone}
\usepackage[utf8]{inputenc}
\usepackage{pgfplots}" > Freq.tex

echo "
\pgfplotstableread[row sep=crcr]{ " > TempTable.tex    

echo "" > TempNode.tex

for FPOD in 0.17e5 0.53e5 1.57e5 0.93e5 1.64e5 1.30e5 2.66e5 3.05e5 3.39e5 3.72e5
do
	echo "1	$FPOD	\\\\\\" >>TempTable.tex
	echo "
%\\\draw [blue,line width=1pt] ( axis cs:1, $FPOD) -- ( axis cs:1.1, $FPOD);
\\\node [anchor=east,right,color=blue!60!black,font=\\\tiny] at (axis cs:1, $FPOD) {$FPOD};" >> TempNode.tex
done


echo "}\FPOD
\pgfplotstableread[row sep=crcr]{ " >> TempTable.tex

for FPGD in 1.65e5 0.17e5 1.67e5 1.80e5 1.51e5 1.52e5 1.59e5 1.56e5 1.56e5 1.62e5
do
	echo "1	$FPGD	\\\\\\" >> TempTable.tex
	echo "
%\\\draw [red,line width=1pt] ( axis cs:1, $FPGD) -- ( axis cs: 0.9, $FPGD);
\\\node [anchor=east,left,color=red!60!black] at (axis cs:1, $FPGD) {$FPGD};" >> TempNode.tex
done


echo "}\FPGD
\pgfplotstableread[row sep=crcr]{ " >> TempTable.tex

for Fprog in 2.5e4 2.5e5
do
	echo "1	$Fprog	\\\\\\" >> TempTable.tex
	echo "
%\\\draw [black,line width=1pt] ( axis cs:1, $Fprog) -- ( axis cs: 0.9, $Fprog);
%\\\node [anchor=east,left,color=black] at (axis cs:1, $Fprog) {$Fprog};" >> TempNode.tex
done


echo "}\Fprog " >> TempTable.tex

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
    ymin=1e4, ymax=5e5,% range for the x axis
    ylabel = Pulsation en $rad^{-1}$
    %\tikzstyle{every node}=[font=\small]
]
\\addplot [only marks, mark size=2.5, mark=square*, fill=blue , draw=blue] table {\FPOD};
\\addplot [only marks, mark=square*, fill=red , draw=red] table {\FPGD};
%\\addplot [only marks, mark=square*, fill=black , draw=black] table {\Fprog};
' >> Freq.tex

cat TempNode.tex >> Freq.tex

echo "
\\\end{axis}
\\\end{tikzpicture}

\\\end{document}" >> Freq.tex

rm TempTable.tex TempNode.tex

pdflatex -shell-escape Freq.tex >> /dev/null