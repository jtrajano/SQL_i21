PRINT 'Create Origin Customer Scripts'
GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspEMCreateOriginCustomer')
	DROP PROCEDURE uspEMCreateOriginCustomer
GO

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN    
    
    EXEC(
            '
            CREATE PROCEDURE uspEMCreateOriginCustomer
                @EntityLocationId			INT
            AS
            BEGIN	
                DECLARE @CusNo					NVARCHAR(10)
                DECLARE @CusLastName			NVARCHAR(25)
                DECLARE @CusFirstName			NVARCHAR(22)
                DECLARE @CusMidInit				NVARCHAR(1)
                DECLARE @CusSuffix				NVARCHAR(2)
                DECLARE @CusZip					NVARCHAR(10)
                DECLARE @CusPhone				NVARCHAR(10)
            
                IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntity 
                                where intEntityId in ( select intEntityId 
                                                            from tblEMEntityType 
                                                                where intEntityId in (select intEntityId 
                                                                                        from tblEMEntityLocation 
                                                                                            where intEntityLocationId = @EntityLocationId) 
                                                                    and strType = ''Customer'' )
                    )
                    
                BEGIN
                    RETURN 0;
                END

                IF EXISTS( SELECT TOP 1 1 FROM tblEMEntityLocation WHERE strOriginLinkCustomer = '''' AND intEntityLocationId = @EntityLocationId)
                BEGIN

                    SELECT 
                        @CusNo				=	CASE WHEN RTRIM(LTRIM(A.strEntityNo)) = '''' THEN RTRIM(LTRIM(B.strLocationName)) ELSE RTRIM(LTRIM(A.strEntityNo)) END
                        ,@CusLastName		=	A.strName
                        ,@CusFirstName		=	A.strName
                        ,@CusMidInit		=	A.strName
                        ,@CusSuffix			=	''''
                        ,@CusZip			=	B.strZipCode
                        ,@CusPhone			=	''''
                        FROM tblEMEntity A				
                            JOIN tblEMEntityLocation B
                                ON A.intEntityId = B.intEntityId and B.intEntityLocationId = @EntityLocationId
                    
                    --SELECT @CusNo, @CusLastName, @CusFirstName, @CusMidInit, @CusSuffix, @CusZip, @CusPhone

                    DECLARE @Count INT
                    SET @Count = 1
                    WHILE EXISTS(SELECT TOP 1 1 FROM agcusmst WHERE agcus_key = @CusNo)
                    BEGIN
                        SET @CusNo = Cast(@Count AS NVARCHAR) +  @CusNo
                        SET @Count = @Count + 1
                    END


                    INSERT INTO agcusmst(
                            agcus_key,			agcus_last_name,		agcus_first_name, 
                            agcus_zip,				agcus_phone)
                    SELECT	@CusNo,				@CusLastName,			@CusFirstName,
                            @CusZip,				@CusPhone


                    UPDATE tblEMEntityLocation 
                        SET strOriginLinkCustomer = @CusNo
                    WHERE intEntityLocationId = @EntityLocationId

                END

            END
            '
        )

    
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN    
    

    EXEC(
            '
            CREATE PROCEDURE uspEMCreateOriginCustomer
                @EntityLocationId			INT
            AS
            BEGIN	
                DECLARE @CusNo					NVARCHAR(10)
                DECLARE @CusLastName			NVARCHAR(25)
                DECLARE @CusFirstName			NVARCHAR(22)
                DECLARE @CusMidInit				NVARCHAR(1)
                DECLARE @CusSuffix				NVARCHAR(2)
                DECLARE @CusZip					NVARCHAR(10)
                DECLARE @CusPhone				NVARCHAR(10)
                
                --insert into ptcusmst(ptcus_cus_no, ptcus_last_name, ptcus_first_name, ptcus_mid_init, ptcus_name_suffx, ptcus_zip, ptcus_phone)

                IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntity 
                                where intEntityId in ( select intEntityId 
                                                            from tblEMEntityType 
                                                                where intEntityId in (select intEntityId 
                                                                                        from tblEMEntityLocation 
                                                                                            where intEntityLocationId = @EntityLocationId) 
                                                                    and strType = ''Customer'' )
                    )
                    
                BEGIN
                    RETURN 0;
                END

                IF EXISTS( SELECT TOP 1 1 FROM tblEMEntityLocation WHERE strOriginLinkCustomer = '''' AND intEntityLocationId = @EntityLocationId)
                BEGIN

                    SELECT 
                        @CusNo				=	CASE WHEN RTRIM(LTRIM(A.strEntityNo)) = '''' THEN RTRIM(LTRIM(B.strLocationName)) ELSE RTRIM(LTRIM(A.strEntityNo)) END
                        ,@CusLastName		=	A.strName
                        ,@CusFirstName		=	A.strName
                        ,@CusMidInit		=	A.strName
                        ,@CusSuffix			=	''''
                        ,@CusZip			=	B.strZipCode
                        ,@CusPhone			=	''''
                        FROM tblEMEntity A				
                            JOIN tblEMEntityLocation B
                                ON A.intEntityId = B.intEntityId and B.intEntityLocationId = @EntityLocationId
                    
                    --SELECT @CusNo, @CusLastName, @CusFirstName, @CusMidInit, @CusSuffix, @CusZip, @CusPhone

                    DECLARE @Count INT
                    SET @Count = 1
                    WHILE EXISTS(SELECT TOP 1 1 FROM ptcusmst WHERE ptcus_cus_no = @CusNo)
                    BEGIN
                        SET @CusNo = Cast(@Count AS NVARCHAR) +  @CusNo
                        SET @Count = @Count + 1
                    END


                    INSERT INTO ptcusmst(
                            ptcus_cus_no,		ptcus_last_name,		ptcus_first_name, 
                            ptcus_mid_init,		ptcus_name_suffx,		ptcus_zip,				ptcus_phone)
                    SELECT	@CusNo,				@CusLastName,			@CusFirstName,
                            @CusMidInit,		@CusSuffix,				@CusZip,				@CusPhone


                    UPDATE tblEMEntityLocation 
                        SET strOriginLinkCustomer = @CusNo
                    WHERE intEntityLocationId = @EntityLocationId

                END

            END
            '
        )
END