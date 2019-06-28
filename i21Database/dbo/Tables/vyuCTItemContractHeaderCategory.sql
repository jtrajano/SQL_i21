CREATE VIEW [dbo].[vyuCTItemContractHeaderCategory]
	
AS 

	SELECT	*
	FROM	(
				SELECT	
						IC.strCategoryCode,
						CH.*						

					FROM	tblCTItemContractHeaderCategory			CH					
					JOIN	tblICCategory							IC	ON	IC.intCategoryId		=		CH.intCategoryId			

			) tblX
