:- use_module(library(lists)).
:- ['donneesTp2.pl'].

/* 0) Le predicat listeFilms(L) lie L à la liste (comportant les identifiants) de tous les films. 
Exemple: 
        ?- listeFilms(ListeDesFilms).
        ListeDesFilms = [sica, nuit, coupe, wind, avengers, iron, sherlock, wind2].
*/
listeFilms(L) :- findall(X, film(X,_,_,_,_,_,_,_,_), L).

/* 
1) 0.25pt. Le predicat listeActeurs(L) unifie L à la liste (comportant les identifiants) de tous les acteurs. 
*/

listeActeurs(L) :- findall(X, acteur(_,_,_,_,X), L).

/* 2) 0.25pt. Le predicat experience(IdAct,Annee,Ne) unifie Ne au nombre d'années d'expérience à l'année Annee, de l'acteur dont 
l"identifiant est IdAct. 
precondition: Annee doit être définie. 
*/ 
anneeDebut(IdAct,Adebut) :- acteur(_,_,_,date(Adebut,_,_),IdAct).
experience(IdAct,Annee,Ne) :- anneeDebut(IdAct,Adebut), Ne is Annee-Adebut.

/* 
3) 0.75pt. Le predicat filtreCritere unifie ActId à l'identifiant du premier acteur qui verifie tous les criteres de Lc. 
precondition: Lc doit etre defini. 
*/									  

filtreCritere([], ActId) :- acteur(_,_,_,_,ActId), !.
filtreCritere([C|[]], ActId) :- A = acteur(_,_,_,_,ActId), critere(C, A), !.
filtreCritere([Head|Tail], ActId) :- A = acteur(_,_,_,_,ActId), critere(Head, A), filtreCritere(Tail, ActId), !.
/* 
4) 0.75pt. Le predicat totalSalaireMin(LActeur,Total) calcule la somme des salaires minimuns exigés par les acteurs dont la liste 
(des identifiants) est spécifiée. 
*/
revenuMinActeur(IdAct,Revenu) :- acteur(_,_,Revenu,_,IdAct).
totalSalaireMin([],Total) :- Total = 0, !.
totalSalaireMin([IdAct|[]],Total) :- revenuMinActeur(IdAct,Total), !.
totalSalaireMin([Head|Tail],Total) :- revenuMinActeur(Head, First), totalSalaireMin(Tail, Sub), Total is First + Sub.

/* 
5a) 0.75pt. Le prédicat selectionActeursCriteres(Lcriteres,Lacteurs) unifie Lacteurs à la liste formée des identifiants des acteurs qui 
satisfont tous les critères de Lcriteres.
precondition: la liste de criteres doit être définie. 
*/
selectionActeursCriteres(Lcriteres, Lacteurs) :- findall(Act,(member(Act,Lacteurs),filtreCritere(Lcriteres, Act)),Lacteurs).

/* 
5b) 1pt. Le prédicat selectionActeursCriteresNouvelle(Lcriteres,Lacteurs,LChoisis) unifie LChoisis à la liste formée des identifiants des 
acteurs sélectionnés parmi les acteurs dans Lacteurs selon 
le principe suivant (jusqu'à concurrence de N acteurs, N correspondant au nombre de critères dans LCriteres: le premier acteur qui 
satisfait le premier critere de Lcriteres, le premier acteur 
non encore sélectionné et qui satisfait le deuxième critère etc.	
precondition: la liste de criteres (Lcriteres) et la liste des acteurs contenant leurs idenfiants (Lacteurs) doivent être définies. 
*/

/*Pris dans les notes de cours*/
del1(X, [X|L], L).
del1(X, [Y|L], [Y|L1]) :- del1(X, L, L1), !. 

filtreCritereNouvelle(_, [], _) :- !, fail.
filtreCritereNouvelle(C, [A|ResteA], ActId) :- \+ critere(C, acteur(_,_,_,_,A)), filtreCritereNouvelle(C, ResteA, ActId), !.
filtreCritereNouvelle(C, [A|_], ActId) :- critere(C, acteur(_,_,_,_,A)), ActId = A, !.

selectionActeursCriteresNouvelle([C|ResteC], Lacteurs, Lchoisis) :- 
  filtreCritereNouvelle(C, Lacteurs, ActId), 
  del1(ActId, Lacteurs, NouvActeur), 
  selectionActeursCriteresNouvelle(ResteC, NouvActeur, NouvChoisis),
  Lchoisis = [ActId|NouvChoisis],
  !.
selectionActeursCriteresNouvelle([],_,[]).

/* 
6) 1pt. Le prédicat filmsAdmissibles(ActId,LFilms) unifie LIdFilms à la liste des films (identifiants) satisfaisant les restrictions 
de l'acteur ActId. 
*/

filtreRestrictions(ActId, Film) :- PFilm=..[film, Film,_,_,_,_,_,_,_,_], PActeur=..[ActId, PFilm], call(PActeur), !.
filmsAdmissibles(ActId, LFilms) :- listeFilms(L), findall(Film,(member(Film,L),filtreRestrictions(ActId, Film)),LFilms).

/* 
7a) 1pt. Le prédicat selectionActeursFilm(IdFilm,Lacteurs) unifie Lacteurs à la liste formée des identifiants d'acteurs pour lesquels 
le film de d'identifiant IdFilm satisfait les restrictions.
préconditions: IdFilm doit être défini 
*/

selectionActeursFilm(IdFilm,Lacteurs) :- listeActeurs(A), findall(ActId,(member(ActId,A),filtreRestrictions(ActId, IdFilm)),Lacteurs).

/* 
7b) 1pt. Le prédicat selectionNActeursFilm2(IdFilm,Lacteurs) unifie Lacteurs à la liste formée des identifiants d'acteurs 
pour lesquels le film de d'identifiant IdFilm satisfait les restrictions.
          Si le nombre total des acteurs qualifiés est inférieur au nombre d'acteurs du film, la liste retournée (Lacteurs) devra 
          contenir l'atome pasAssezDacteur.
préconditions: IdFilm doit être défini 
*/
trim([X|_], 1, SubList) :- SubList = [X].
trim([X|XS], N, SubList) :- N2 is N - 1, trim(XS,N2,NewSubList), SubList = [X|NewSubList], !.

selectionNActeursFilm2(IdFilm,pasAssezDacteur) :- film(IdFilm,_,_,_,_,_,_,N,_), selectionActeursFilm(IdFilm,Lacteurs), length(Lacteurs, NbAct), N > NbAct, !.  
selectionNActeursFilm2(IdFilm,Lacteurs) :- film(IdFilm,_,_,_,_,_,_,N,_), selectionActeursFilm(IdFilm,LacteursComplet), trim(LacteursComplet, N, Lacteurs), !.

/* 
8) 1pt. Le prédicat acteurJoueDansFilm(Lacteurs, IdFilm) ajoute dans la base de faits tous les acteurs (identifiants) jouant dans 
le film de titre spécifié (IdFilm) 
*/

acteurJoueDansFilm([X|[]], IdFilm) :- assert(joueDans(X, IdFilm)),!.
acteurJoueDansFilm([X|XS], IdFilm) :- assert(joueDans(X, IdFilm)), acteurJoueDansFilm(XS, IdFilm),!.

/* 
9a) 1pt. Le prédicat affectationDesRolesSansCriteres(IdFilm) a pour but de distribuer les rôles à une liste d'acteurs pouvant jouer 
dans le film identifié par IdFilm (puisque
le film satisfait à ses restrictions). Les N premiers acteurs dont les restructions sont respectées par le film (N correspondant au 
nombre de rôles du film), sont ajoutés dans
dans la base de faits par des prédicats "joueDans".
Ce prédicat modifie le fait film correspondant à IdFilm par destruction et remplacement par un nouveau fait film égal à l'ancien mais 
dont le budget a été remplacé par la somme des salaires minimums des acteurs choisis et son coût a été diminué de la différence entre 
le budget initial et le nouveau budget.
Ce prédicat complète la base de faits joueDans(IdActeur, IdFilm) en fonction des N acteurs sélectionnés et dont la somme des salaires 
minimums est inférieure ou égale au budget (salarial) du film. Le prédicat doit envisager toutes les combinaisons possibles des N acteurs 
tirés de la base de faits acteur 
Le prédicat échoue et ne modifie rien si une des conditions suivantes est vérifiée (dans l'ordre):
  0) les rôles ont déjà été distribués por ce film
  1) le réalisateur du film est pasDeRealisateur
  2) le producteur du film est pasDeProducteur
  3) s'il n'y a pas assez d'acteurs,
  4) si le budget du film est insuffisant.
précondition: L'identifiant du film doit être défini.
*/

sommeSalaire([X|[]], S) :- acteur(_,_,S,_,X), !. 
sommeSalaire([X|XS], S) :- acteur(_,_,R,_,X), sommeSalaire(XS, NewS), S is R + NewS, !. 

affectationDesRolesSansCriteres(IdFilm) :- 
  listeActeurs(A), 
  findall(ActId,(member(ActId,A),joueDans(ActId,IdFilm)),Lacteurs), 
  length(Lacteurs, Na),
  film(IdFilm,_,_,_,_,_,_,N,_),
  Na =:= N,
  !, fail.
affectationDesRolesSansCriteres(IdFilm) :- film(IdFilm,_,_,pasDeRealisateur,_,_,_,_,_), !, fail.
affectationDesRolesSansCriteres(IdFilm) :- film(IdFilm,_,_,_,pasDeProducteur,_,_,_,_), !, fail.
affectationDesRolesSansCriteres(IdFilm) :- selectionNActeursFilm2(IdFilm,pasAssezDacteur), !, fail.
affectationDesRolesSansCriteres(IdFilm) :- 
  listeActeurs(A), 
  findall(ActId,(member(ActId,A),joueDans(ActId,IdFilm)),LacteursAssignes),
  selectionNActeursFilm2(IdFilm,LacteursAdmissibles),
  subtract(LacteursAdmissibles, LacteursAssignes, Lacteurs),
  sommeSalaire(Lacteurs, S), 
  film(IdFilm,_,_,_,_,_,_,_,B),
  S > B, 
  !,fail.
affectationDesRolesSansCriteres(IdFilm) :- 
  listeActeurs(A), 
  findall(ActId,(member(ActId,A),joueDans(ActId,IdFilm)),LacteursAssignes),
  selectionNActeursFilm2(IdFilm,LacteursAdmissibles),
  subtract(LacteursAdmissibles, LacteursAssignes, Lacteurs), 
  sommeSalaire(Lacteurs, S), 
  film(IdFilm,T,Type,R,P,Ci,D,N,Bi),
  retract(film(IdFilm,_,_,_,_,_,_,_,_)),
  Cn is Ci - (Bi - S),
  assert(film(IdFilm,T,Type,R,P,Cn,D,N,S)),
  acteurJoueDansFilm(Lacteurs, IdFilm), !.

/*
9b) 1pt. Le prédicat affectationDesRolesCriteres(IdFilm,Lcriteres,LChoisis) unifie LChoisis à la liste d'acteurs satisfaisant aux 
critères de sélection du film, Ce film doit bien entendu satisfaire aux restrictions de 
chacun des acteurs candidat. 
Dans ce prédicat, IdFilm est un identifiant de film et Lcriteres est une liste de critères. 
Pour la satisfaction des critère, on retiendra toujours le premier acteur satisfaisant au 1er critère et on recommensera avec le 
même principe pour les autres acteurs et les critères restants.
Contrairement au prédicat affectationDesRolesSansCriteres défini à la question 9a, affectationDesRolesCriteres ne modifie pas ba 
base de faits et se contente de récupérer la liste des acteurs sélectionnés dans Lchoisis.
Le prédicat échoue
  1) si la liste des critère est vide,
  2) si le réalisateur du film est pasDeRealisateur,
  3) si le producteur du film est pasDeProducteur,
  4) s'il n'y a pas assez d'acteurs.
précondition: L'identifiant du film et la liste de critères doivent être définis.
Attention: Il est possible qu'il y ait moins de critère que d'acteurs admissibles. Dans ce cas, la liste des acteurs sélectionnés 
ne peut dépasser le nombre de critères dans Lcriteres.
           Le nombre maximum d'acteurs choisis est donc égal à la taille de la liste Lcriteres.
*/

affectationDesRolesCriteres(_,[],_) :- !, fail.
affectationDesRolesCriteres(IdFilm,_,_) :- film(IdFilm,_,_,pasDeRealisateur,_,_,_,_,_), !, fail.
affectationDesRolesCriteres(IdFilm,_,_) :- film(IdFilm,_,_,_,pasDeProducteur,_,_,_,_), !, fail.
affectationDesRolesCriteres(IdFilm,Lcriteres,LChoisis) :- 
  listeActeurs(A),
  findall(ActId,(member(ActId,A),filtreRestrictions(ActId, IdFilm)),Lacteurs), 
  selectionActeursCriteresNouvelle(Lcriteres,Lacteurs,LChoisis),!.

/*
10) 2pts. Le prédicat affectationDesRoles(IdFilm, Lcriteres) a pour but de distribuer les rôles à une liste d'acteurs pouvant 
jouer dans le film et satisfaisant
aux critères de sélection du film en ajoutant les acteurs choisis dans la base de faits "joueDans".
Dans ce prédicat, IdFilm est un identifiant de film et Lcriteres est une liste de critères. 
Pour la satisfaction des critère, on retiendra toujours le premier acteur satisfaisant au 1er critère et on recommensera avec 
le même principe pour les autres acteurs et les critères restants.
Ce prédicat modifie le fait film correspondant à IdFilm par destruction et remplacement par un nouveau fait film égal à l'ancien 
mais dont le budget a été remplacé par la somme des salaires minimums des acteurs choisis et son coût a été diminué de la différence 
entre le budget initial et le nouveau budget.
Ce prédicat complète la base de faits joueDans(IdActeurActeur, IdFilm) en fonction des n acteurs sélectionnés (où n est le nombre 
de rôles du film) qui satisfont tous les critères de Lcriteres, pour lesquels le film satisfait leur restrictions et dont la somme 
des salaires minimums est inférieure ou égale au budget du film. 
Le prédicat doit envisager toutes les combinaisons possibles des n acteurs tirés de la base de faits acteur.
Le prédicat échoue et ne modifie rien 
  1) si le réalisateur du film est pasDeRealisateur,
  2) si le producteur du film est pasDeProducteur,
  3) s'il n'y a pas assez d'acteurs,
  4) si le budget du film est insuffisant pour financer le salaire minimum de tous acteurs sélectionnés.
précondition: L'identifiant du film et la liste de critères doivent être définis.
Attention: 
1) Il est possible qu'il y ait moins de critère que d'acteurs admissibles. Dans ce cas, la liste des acteurs sélectionnés doit être
 complétée (si possible et à concurrence de nombre de rôles) selon le principe du prédicat affectationDesRolesSansCriteres(IdFilm) 
 de la question 9a.
2) Si la liste Lcriteres est vide, c'est aussi le principe de affectationDesRolesSansCriteres(IdFilm) de la question 9a qui s'applique.
*/

affectationDesRoles(IdFilm,_) :- film(IdFilm,_,_,pasDeRealisateur,_,_,_,_,_), !, fail.
affectationDesRoles(IdFilm,_) :- film(IdFilm,_,_,_,pasDeProducteur,_,_,_,_), !, fail.
affectationDesRoles(IdFilm,[]) :- affectationDesRolesSansCriteres(IdFilm), !.
affectationDesRoles(IdFilm, Lcriteres) :- 
  film(IdFilm,_,_,_,_,_,_,_,B), 
  affectationDesRolesCriteres(IdFilm,Lcriteres,LChoisis),
  sommeSalaire(LChoisis, S),
  S > B,
  !,
  fail.
affectationDesRoles(IdFilm, Lcriteres) :- 
  film(IdFilm,T,Type,R,P,Ci,D,N,Bi), 
  affectationDesRolesCriteres(IdFilm,Lcriteres,LChoisis),
  length(LChoisis, N2),
  N > N2,
  listeActeurs(A),
  findall(ActId,(member(ActId,A),filtreRestrictions(ActId, IdFilm)),Lacteurs), 
  subtract(Lacteurs, LChoisis, LacteursAdmissibles),
  M is N - N2,
  trim(LacteursAdmissibles, M, LacteursAdd),
  append(LChoisis, LacteursAdd, LChoisisComplet),
  sommeSalaire(LChoisisComplet, S),
  retract(film(IdFilm,_,_,_,_,_,_,_,_)),
  Cn is Ci - (Bi - S),
  assert(film(IdFilm,T,Type,R,P,Cn,D,N,S)),
  acteurJoueDansFilm(LChoisisComplet, IdFilm),
  !.
affectationDesRoles(IdFilm, Lcriteres) :- 
  film(IdFilm,T,Type,R,P,Ci,D,N,Bi), 
  affectationDesRolesCriteres(IdFilm,Lcriteres,LChoisis),
  sommeSalaire(LChoisis, S),
  retract(film(IdFilm,_,_,_,_,_,_,_,_)),
  Cn is Ci - (Bi - S),
  assert(film(IdFilm,T,Type,R,P,Cn,D,N,S)),
  write('N == N2'), nl,
  acteurJoueDansFilm(LChoisis, IdFilm),
  !.

/* 11) 1,25 pts. Le prédicat produire(NomMaison,IdFilm) vérifie si la maison peut produire le film identifié. Il vérifie si le 
budget de la maison 
est supérieur au cout du film, si le réalisateur n'est pas pasDeRealisateur, et si le producteur n'est pas pasDeProducteur. Si la 
production est possible,
 on diminue le budget de la maison par le coût du film et on remplace le fait 'film' par un nouveau film égal à l'ancien sauf que 
 la composante producteur 
 est égale à NomMaison. 
 Précondition: le nom de la maison et l'identifiant du film doivent être connus. Le prédicat doit échoué si la maison ne peut pas 
 produire le film. 
*/

produire(NomMaison,IdFilm) :- maison(NomMaison,B), film(IdFilm,_,_,_,_,C,_,_,_), B < C, !, fail.  
produire(_,IdFilm) :- film(IdFilm,_,_,pasDeRealisateur,_,_,_,_,_), !, fail.
produire(_,IdFilm) :- \+ film(IdFilm,_,_,_,pasDeProducteur,_,_,_,_), !, fail.
produire(NomMaison, IdFilm) :- 
  maison(NomMaison,B), 
  film(IdFilm,T,Type,R,_,C,D,N,Bi), 
  NouvB is B - C,
  retract(maison(NomMaison,B)),
  assert(maison(NomMaison,NouvB)),
  retract(film(IdFilm,_,_,_,_,_,_,_,_)),
  assert(film(IdFilm,T,Type,R,NomMaison,C,D,N,Bi)), 
  !.
							 
/* 12) 0.75pt. Le prédicat plusieursFilms(N,Lacteurs) unifie Acteurs à la liste des acteurs (comportant leurs NOMS), qui jouent 
dans au moins N films.
N doit être lié à une valeur au moment de la requête de résolution du but 
*/

nombreFilmsActeur(NomAct, N) :- 
  listeFilms(F),
  acteur(NomAct,_,_,_,IdAct),
  findall(IdFilm,(member(IdFilm,F),joueDans(IdAct,IdFilm)),Lfilms), 
  length(Lfilms, N).

listeNomsActeurs(L) :- findall(X, acteur(X,_,_,_,_), L).

plusieursFilms(N,Lacteurs) :- 
  listeNomsActeurs(A),
  findall(NomAct,(member(NomAct,A),nombreFilmsActeur(NomAct,N2), N2 >= N),Lacteurs).

/* 13) 1.25pt. Les films réalisés et produits doivent maintenant être distribués dans les cinémas. On vous demande définir le 
prédicat distribuerFilm(IdFilm,PrixEntree) qui envoie le film identifié par IdFilm à tous les cinémas en spécifiant le prix d'entrée suggéré. 
Ce prédicat doit modifier la base de connaissances en ajoutant le triplet  (IdFilm,0,PrixEntree) dans le répertoire de chacun 
des cinémas déjà existants.
 */

listeCinemas(C) :- findall(X, cinema(X, _, _), C).

ajouterFilmRepetoire(IdCin, IdFilm, PrixEntree) :- 
  cinema(IdCin, N, Rep),
  append(Rep, [(IdFilm, 0, PrixEntree)], NouvRep),
  retract(cinema(IdCin, N, Rep)),
  assert(cinema(IdCin, N, NouvRep)),
  !.

/*Depuis les notes de cours*/
map(NomFonction, [H|T], Arg1, Arg2) :- 
  Fonction=..[NomFonction, H, Arg1, Arg2],
  call(Fonction),
  map(NomFonction, T, Arg1, Arg2).
map(_,[],_,_).

distribuerFilm(IdFilm,_) :- film(IdFilm,_,_,pasDeRealisateur,_,_,_,_,_), !, fail. 
distribuerFilm(IdFilm,_) :- film(IdFilm,_,_,_,pasDeProducteur,_,_,_,_), !, fail. 
distribuerFilm(IdFilm,PrixEntree) :- 
  listeCinemas(Lcinemas),
  map(ajouterFilmRepetoire,Lcinemas, IdFilm, PrixEntree),
  !.