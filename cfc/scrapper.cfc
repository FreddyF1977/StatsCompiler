component displayname="Scrapper" output="false" hint="Scrapper Component" accessors="true" {
	property type="string" name="MainURL" default="http://www.lhro.ca/index.php" setter="false";
	property type="string" name="UrlVar" default="?page=stats&entity=game&action=editstatsdetail" setter="false";

	public scrapper function init() {
		variables.oJsoup = createObject("java", "org.jsoup.Jsoup");
		return this;
	}

	public struct function SommaireBut(required numeric IdPartie) {
		var Sommaire = jSoupConnect(arguments.IdPartie, 'scoring');
		var arrGoalTable = Sommaire.select('table.inner tr'); // Tableau des rangées de la table avec comme classe inner
		var objSommaire = {}; //Object contenant les propriétés d'une partie
		var objSommaire.Periode = []; //Object contenant un tableau des périodes
		var objBut = {}; //Object contenant un tableau des buts
		var cntPeriode = 0;
		var Marqueur = '';
		var AssistantsList = '';
		var CleanString = '';
		var PlayerStringPosition = [];

		for (var GoalRow in arrGoalTable) {
			if (ListFind('Période 1,Période 2,Période 3', StringSanitizer(GoalRow.select('td[colspan=3]').html()))) {
				cntPeriode++;
				objSommaire.Periode[cntPeriode] = {};
				objSommaire.Periode[cntPeriode].buts = [];
			}

			if (GoalRow.select('td').len() GT 1) {
				objBut = {};
				objBut.Temps = StringSanitizer(GoalRow.select('td')[1].html()); //Temps du but
				objBut.Equipe = StringSanitizer(GoalRow.select('td')[2].html()); // Nom de l'équipe

				objBut.Assistances = [];
				objBut.Marqueur = {};

				CleanString = StringSanitizer(GoalRow.select('td')[3].html()); // Chaine de charactères contenant l'information des joueurs ayant participé au but.
				PlayerStringPosition = reFindNoCase("\(([^]]+)\)", CleanString, 1, "true");

				Marqueur = mid(CleanString, 1, PlayerStringPosition.pos[1] - 1); //Chaine de charactères du marqueur
				objBut.Marqueur.Numero =  Marqueur.ListGetAt(1,'-');
				objBut.Marqueur.Nom =  NomDuJoueur(Marqueur);

				AssistantsList = mid(CleanString, PlayerStringPosition.pos[2], PlayerStringPosition.len[2]); //Chaine de charactères du/des assistants
				for(var i = 1; i <= ListLen(AssistantsList); i++){ //Boucle sur les assistants
					objBut.Assistances[i] = {};

					if(ListLen(ListGetAt(AssistantsList,i), '-') > 1) {
						objBut.Assistances[i].Numero = ListGetAt(ListGetAt(AssistantsList,i), 1, '-'); // Numéro du joueur
						objBut.Assistances[i].Nom = NomDuJoueur(ListGetAt(AssistantsList,i)); // Nom du joueur
					} else {
						objBut.Assistances[i].Numero = 0;
						objBut.Assistances[i].Nom = ListGetAt(AssistantsList,i);
					}
				}

				ArrayAppend(objSommaire.Periode[cntPeriode].buts, objBut);
			}
		}

		return objSommaire;
	}

	public struct function SommairePenality(required numeric IdPartie) {
		var Sommaire = jSoupConnect(arguments.IdPartie, 'pens');
		var objSommaire = {}; //Object contenant les propriétés d'une partie
		var objSommaire.Periode = []; //Object contenant un tableau des périodes
		var objPenality = {}; //Object contenant un tableau des penalité
		var cntPeriode = 0;
		var Joueur = '';
		var CleanString = '';
		var penalityString = '';
		var arrPenaltyTable = Sommaire.select('table.inner tr');

		for (var PenaltyRow in arrPenaltyTable) {
			if (cntPeriode <= 3) {
				if (PenaltyRow.select('td[colspan=3]').html() IS NOT '' && cntPeriode < 3) {
					cntPeriode++;
					objSommaire.Periode[cntPeriode] = {};
					objSommaire.Periode[cntPeriode].Penality = [];
				}

				if (PenaltyRow.select('td').len() GT 1) {
					objPenality = {};
					objPenality.Temps = StringSanitizer(PenaltyRow.select('td')[1].html()); //Temps du but
					objPenality.Equipe = StringSanitizer(PenaltyRow.select('td')[2].html()); // Nom de l'équipe

					CleanString = StringSanitizer(PenaltyRow.select('td')[3].html()); // Chaine de charactères contenant l'information des joueurs ayant participé au but.
					PlayerStringPosition = reFindNoCase("\(([^]]+)\)", CleanString, 1, "true");
					Joueur = mid(CleanString, 1, PlayerStringPosition.pos[1] - 1); //Chaine de charactères du marqueur

					objPenality.Joueur = {};
					objPenality.Joueur.Numero =  Joueur.ListGetAt(1,'-');
					objPenality.Joueur.Nom =  NomDuJoueur(Joueur);

					penalityString = PenaltyRow.select('td')[4].html(); // Chaine de charactères contenant l'information sur la pénalité.

					for (var i = 1; i <= ListLen(penalityString, ' '); i++) {
						if (i == 1) {
							objPenality.Code = ListGetAt(penalityString, i, ' ');
							objPenality.Penality = '';
						} else if (i > 1 && i < ListLen(penalityString, ' ')) {
							objPenality.Penality = ListAppend(objPenality.Penality, ListGetAt(penalityString, i, ' '), ' ');
						} else {
							objPenality.Minutes = reReplace(ListGetAt(penalityString, i, ' '), '[^0-9\.]', '', 'All');
						}
					}

					ArrayAppend(objSommaire.Periode[cntPeriode].Penality, objPenality);
				}
			}
		}

		return objSommaire;
	}

	public struct function InfoPartie(required numeric IdPartie) {
		var Info = jSoupConnect(arguments.IdPartie, 'info');
		var arrInfoTable = Info.select('.stats-scoringsheet tr').mid(1,8); // Tableau des rangées de la table avec comme classe stats-scoringsheet (seulement les 8 premiers éléments)
		var objInfo = {}; //Object contenant les propriétés d'une partie

		for (var infoRow in arrInfoTable) {
			objInfo[StringSanitizer(infoRow.select('td')[1].html())] = StringSanitizer(infoRow.select('td')[2].html());
		}

		objInfo['pageId'] = arguments.IdPartie;

		return objInfo;
	}

	private object function jSoupConnect(required numeric IdPartie, required string tab){
		return variables.oJsoup.connect(variables.MainURL & variables.UrlVar & '&tab=' & arguments.tab & '&id=' & arguments.IdPartie).get();
	}

	// Crude sanitizer to remove tags we don't need from the string - might improve in the future if needs be
	private string function StringSanitizer(required string string) {
		var SanitizedString = arguments.string;

		SanitizedString = reReplaceNoCase(SanitizedString, "<a[^>]*>(.*?)<\/a>", "\1", "All"); //Remove href
		SanitizedString = reReplaceNoCase(SanitizedString, "(&nbsp;)|<span>|<\/span>|<b>|<\/b>|<td>|<\/td>", "", "All"); //Remove non breaking space and spans

		return SanitizedString;
	}

	private string function NomDuJoueur(required string nom) {
		//Premier segment de la chaine de charactère est le numéro du joueur - Trim, Mettre la première lettre en majuscule
		var nomFormate = trim(UcFirst(lcase(ListGetAt(arguments.nom, 2, '-')), true))

		if(ListLen(arguments.nom, '-') >= 3) { // Si le nom du joueur est composé
			for (var i=3; i <= ListLen(arguments.nom, '-'); i++) {
				nomFormate = ListAppend(nomFormate, trim(UcFirst(lcase(ListGetAt(arguments.nom, i, '-')), true)), '-');
			}
		}

		return nomFormate;
	}
}
