<cfscript>
	oJsoup = createObject("java", "org.jsoup.Jsoup");

	doc = oJsoup.connect("http://www.lhro.ca/index.php?page=stats&entity=game&action=editstatsdetail&id=3586&tab=scoring").get();
	//doc = oJsoup.connect("http://www.lhro.ca/index.php?page=stats&entity=game&action=editstatsdetail&id=3631&tab=scoring").get();

	arrGoalTable = doc.select('table.inner tr'); // Tableau des rangées de la table avec comme classe inner

	objPartie = {}; //Object contenant les propriétés d'une partie
	objPartie.Periode = []; //Object contenant un tableau des périodes
	cntPeriode = 0;

	for (GoalRow in arrGoalTable){
		if (GoalRow.select('td[colspan=3]').html() IS NOT '') {
			cntPeriode++;
			objPartie.Periode[cntPeriode] = {};
			objPartie.Periode[cntPeriode].buts = [];
		}

		if (GoalRow.select('td').len() GT 1){
			objBut = {};
			objBut.Temps = StringSanitizer(GoalRow.select('td')[1].html()); //Temps du but
			objBut.Equipe = StringSanitizer(GoalRow.select('td')[2].html()); // Nom de l'équipe

			objBut.Assistances = [];
			objBut.Marqueur = {};

			CleanString = StringSanitizer(GoalRow.select('td')[3].html()); // Chaine de charactères contenant l'information des joueurs ayant participé au but.
			PlayerStringPosition = reFindNoCase("\(([^]]+)\)", CleanString, 1, "true");

			Marqueur =  mid(CleanString, 1, PlayerStringPosition.pos[1] - 1); //Chaine de charactères du marqueur
			objBut.Marqueur.Numero =  Marqueur.ListGetAt(1,'-');
			objBut.Marqueur.Nom =  NomDuJoueur(Marqueur);

			AssistantsList = mid(CleanString, PlayerStringPosition.pos[2], PlayerStringPosition.len[2]); //Chaine de charactères du/des assistants
			for(var j = 1; j <= ListLen(AssistantsList); j++){ //Boucle sur les assistants
				objBut.Assistances[j] = {};

				if(ListLen(ListGetAt(AssistantsList,j), '-') > 1){
					objBut.Assistances[j].Numero = ListGetAt(ListGetAt(AssistantsList,j), 1, '-'); // Numéro du joueur
					objBut.Assistances[j].Nom = NomDuJoueur(ListGetAt(AssistantsList,j)); // Nom du joueeur
				} else {
					objBut.Assistances[j].Numero = 0;
					objBut.Assistances[j].Nom = ListGetAt(AssistantsList,j);
				}
			}
			ArrayAppend(objPartie.Periode[cntPeriode].buts, objBut);
		}
	}

	WriteDump(objPartie);

	// Crude sanitizer to remove tags we don't need from the string - might improve in the future if needs be
	function StringSanitizer(string string){
		var SanitizedString = string;

		SanitizedString = reReplaceNoCase(SanitizedString, "<a[^>]*>(.*?)<\/a>", "\1", "All"); //Remove href
		SanitizedString = reReplaceNoCase(SanitizedString, "(&nbsp;)|<span>|<\/span>|<b>|<\/b>|<td>|<\/td>", "", "All"); //Remove non breaking space and spans

		return SanitizedString;
	}

	function NomDuJoueur(string string){
		var nom = trim(UcFirst(lcase(ListGetAt(string, 2, '-')), true)) //Trim, Mettre la première lettre en majuscule

		if(ListLen(string, '-') >= 3){ // Si le nom du joueur est composé
			for (var i=3; i <= ListLen(string, '-'); i++){
				nom = ListAppend(nom, trim(UcFirst(lcase(ListGetAt(string, i, '-')), true)), '-');
			}
		}

		return nom;
	}
</cfscript>