component displayname="equipe Accessor" output="false" hint="Accesseur des equipes" {
	public query function equipeList() {
		var rsequipe = QueryNew('equipeId,equipe','integer,varchar');

        rsequipe = queryExecute("
                SELECT
                    EquipeId,
                    Equipe,
                    Association,
                    Categorie,
                    Niveau
                FROM
                    LHROScore.equipe
                    INNER JOIN
                        LHROScore.association
                        ON LHROScore.equipe.fkAssociationid = LHROScore.association.associationId
                    INNER JOIN
                        LHROScore.categorie
                        ON LHROScore.equipe.fkCategorieId = LHROScore.categorie.categorieId
                    INNER JOIN
                        LHROScore.niveau
                        ON LHROScore.equipe.fkNiveauId = LHROScore.niveau.niveauId
                ORDER BY
                    Association,
                    Equipe    
            ",
            {},
            {
                datasource:"lhro"
            }
        );

		return rsequipe;
	}

	public query function equipeByArgs(required struct args) {
		var rsequipe = QueryNew('equipeId,equipe','integer,varchar');
        var condition = '';
        var paramstruct = {};

        if (!arguments.args.isEmpty()){
            if (arguments.args.keyExists('nomEquipe')){
                condition = '
                    AND
                    equipe = :equipe
                ';
                paramStruct.append({equipe:{value=arguments.args.nomEquipe, cfsqltype="varchar"}});
            }

            if (arguments.args.keyExists('niveau')){
                condition = condition & '
                    AND
                    fkNiveauId = :niveau
                ';
                paramStruct.append({niveau:{value=arguments.args.niveau, cfsqltype="integer"}});
            }

            if (arguments.args.keyExists('categorie')){
                condition = condition & '
                    AND
                    fkCategorieId = :categorie
                ';
                paramStruct.append({categorie:{value=arguments.args.categorie, cfsqltype="integer"}});
            }
        }

        rsequipe = queryExecute("
                SELECT
                    equipeId,
                    equipe,
                    fkCategorieId,
                    fkNiveauId,
                    fkAssociationId
                FROM
                    equipe
                WHERE
                    1 = 1
                    #Condition#
            ",paramStruct,
            {
                datasource:"lhro"
            }
        );

		return rsequipe;
	}
}