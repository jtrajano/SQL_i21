﻿CREATE PROCEDURE [dbo].[uspCTGetTerms]
	@intEntityId	INT,
	@intTermID		INT,
	@strTerm		NVARCHAR(500)	
AS

BEGIN

	IF (SELECT COUNT(*) FROM  tblAPVendorTerm WHERE intEntityVendorId = ISNULL(@intEntityId,0)) <= 1
	BEGIN
		SELECT	TM.intTermID,
				TM.strTerm
		FROM	tblSMTerm	TM
		WHERE	TM.strTerm  LIKE '%' + @strTerm + '%'
		AND		TM.intTermID =(CASE WHEN @intTermID > 0 THEN @intTermID ELSE TM.intTermID END)
	END		
	ELSE
	BEGIN
		SELECT	TM.intTermID,
				TM.strTerm
		FROM	tblAPVendorTerm	VT
		JOIN	tblSMTerm	TM ON VT.intTermId = TM.intTermID AND VT.intEntityVendorId = @intEntityId
		WHERE	TM.strTerm  LIKE '%' + @strTerm + '%'
		AND		TM.intTermID =(CASE WHEN @intTermID > 0 THEN @intTermID ELSE TM.intTermID END)
	END

END
