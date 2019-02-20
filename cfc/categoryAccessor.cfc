component displayname="Categorie Accessor" output="false" hint="Accesseur des categories" {
	public query function categoryList() {
		var rsCategory = QueryNew('categorieId,categorie','integer,varchar');

        rsCategory = queryExecute("
                SELECT
                    categorieId,
                    categorie
                FROM
                    categorie    
            ",
            {},
            {
                datasource:"lhro"
            }
        );

		return rsCategory;
	}

	public query function categoryByName(required string categorie) {
		var rsCategory = QueryNew('categorieId,categorie','integer,varchar');

        rsCategory = queryExecute("
                SELECT
                    categorieId,
                    categorie
                FROM
                    categorie
                WHERE
                    categorie = :categorie       
            ",
            {
                categorie:arguments.categorie
            },
            {
                datasource:"lhro"
            }
        );

		return rsCategory;
	}
}