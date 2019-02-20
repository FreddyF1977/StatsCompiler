component displayname="Niveau Accessor" output="false" hint="Accesseur des Niveaus" {
	public query function NiveauList() {
		var rsNiveau = QueryNew('NiveauId,Niveau','integer,varchar');

        rsNiveau = queryExecute("
                SELECT
                    NiveauId,
                    Niveau
                FROM
                    niveau    
            ",
            {},
            {
                datasource:"lhro"
            }
        );

		return rsNiveau;
	}

	public query function NiveauByName(required string Niveau) {
		var rsNiveau = QueryNew('NiveauId,Niveau','integer,varchar');

        rsNiveau = queryExecute("
                SELECT
                    NiveauId,
                    Niveau
                FROM
                    niveau
                WHERE
                    Niveau = :Niveau       
            ",
            {
                Niveau:arguments.Niveau
            },
            {
                datasource:"lhro"
            }
        );

		return rsNiveau;
	}
}