IF EXISTS(SELECT 1 FROM tblAPVendor WHERE intGLAccountExpenseId = 0)
BEGIN

	UPDATE A
		SET intGLAccountExpenseId = NULL
	FROM tblAPVendor A
	WHERE A.intGLAccountExpenseId = 0

END