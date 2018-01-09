GO
IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccountSystem WHERE strAccountSystemDescription = 'Origin')
	BEGIN
		PRINT('Begin creating initial Origin account mapping for new company')
		INSERT INTO tblGLAccountSystem(strAccountSystemDescription,ysnSystem, intConcurrencyId)
		VALUES('Origin',1,1)
		PRINT('Finished creating initial Origin account mapping for new company')
	END
GO