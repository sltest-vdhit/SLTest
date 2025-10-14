This is the study regulation in SemaLogic notation: Current state: 720 solutions.
SemaLogic(transfer to ASP.json to endpoint https://studyregulation-stage.cavas.uni-potsdam.de/plans/count)

§1
Part time application 0|1 {[proof of consultation, individual examination plan]}

§2
Master of Science [necessary credit points, Cognitive Systems, 0|1 {Part time application}]

§4
¿[Decision Examining Board, Bachelor of Science] ⇾ Cognitive Systems;?
Master of Science.regular duration := four semesters;
necessary credit points := (sum(Cognitive Systems.Leaf, ECTS) == 120);

§5
¿ sum(Mandatory Modules.Leaf, ECTS) == 27?
Mandatory Modules [BM1, BM2, BM3]
Mandatory Modules.Leaf.ECTS := 9;

¿ sum(Optional Modules.Leaf, ECTS) == 24?
Optional Modules 4|4 {AM11, AM12, AM21, AM22, AM31, AM32, Bridge Modules}
Optional Modules.Leaf.ECTS := 6;
Bridge Modules ~FM1, FM2, FM3~
Decision Examining Board 0|2 {Bridge Modules}

¿ sum(Project Seminars.Leaf, ECTS) == 24?
Project Seminars 2|3 { PM1, PM2, PM3 }
Project Seminars.Leaf.ECTS := 12;

¿ sum (Scholarly Work Methods, ECTS) == 15?
Scholarly Work Methods [IM1]
IM1.ECTS := 15;

Masters Thesis.This.ECTS := 30;
Thesis [Masters Thesis, Oral Exam, Get Thesis Topic]
Get Thesis Topic ⇾ Masters Thesis;
Masters Thesis ⇾ Oral Exam; // this is just implicit!
Courseload ⇾ Thesis;

Cognitive Systems [Thesis, Courseload]
Courseload [Scholarly Work Methods, Mandatory Modules, Optional Modules, Project Seminars]

§6
Get Thesis Topic { Enough credits, [Some Credits, Registered for Examination] }
Enough credits := (sum (Courseload.Leaf, ECTS) >= 90);
Registered for Examination := (30 <= sum (Courseload.Leaf, ECTS, Registered Exams));
Some Credits := (sum (Courseload.Leaf, ECTS) >= 60);

§7
¡more spend time abroad ⥢ [Masters Thesis, Project Seminars, IM1];!
¡spend time abroad ⇽ [Mandatory Modules, Optional Modules];!

Note: The appendix with the module catalogue is omitted in this version. For further details, see the formal language version of the study regulations.
