#!/bin/sh
echo "
\documentclass{standalone}
\usepackage[utf8]{inputenc}
\usepackage{pgfplots}" > Freq.tex

echo "
\pgfplotstableread[row sep=crcr]{ " > TempTable.tex    

echo "" > TempNode.tex

for Fpropre in 2.59e3 7.69e3 1.29e4 1.82e4 2.36e4 2.87e4
do
	echo "1	$Fpropre	\\\\\\" >>TempTable.tex
	echo "
%\\\draw [blue,line width=1pt] ( axis cs:1, $Fpropre) -- ( axis cs:1.1, $Fpropre);
\\\node [anchor=east,right,color=blue!60!black] at (axis cs:1, $Fpropre) {$Fpropre};" >> TempNode.tex
done


echo "}\Fpropre
\pgfplotstableread[row sep=crcr]{ " >> TempTable.tex

for Fcharge in 4.00e3 5.00e3 6.25e3 8.33e3 1.25e4 1.67e4 2.50e4
do
	echo "1	$Fcharge	\\\\\\" >> TempTable.tex
	echo "
%\\\draw [red,line width=1pt] ( axis cs:1, $Fcharge) -- ( axis cs: 0.9, $Fcharge);
\\\node [anchor=east,left,color=red!60!black] at (axis cs:1, $Fcharge) {$Fcharge};" >> TempNode.tex
done


echo "}\Fcharge " >> TempTable.tex

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
    ymin=2e3, ymax=4e4,% range for the x axis
    ylabel = Frequence en $s^{-1}$
]
\\addplot [only marks, mark size=2.5, mark=square*, fill=blue , draw=blue] table {\Fpropre};
\\addplot [only marks, mark=square*, fill=red , draw=red] table {\Fcharge};
' >> Freq.tex

cat TempNode.tex >> Freq.tex

echo "
\\\end{axis}
\\\end{tikzpicture}

\\\end{document}" >> Freq.tex

rm TempTable.tex TempNode.tex

pdflatex -shell-escape Freq.tex >> /dev/null