CREATE VIEW vyuCTEntity
AS
	SELECT	E.intEntityId,
			E.strName			AS strEntityName,
			Y.strType			AS strEntityType,
			E.strEntityNo		AS strEntityNumber,
			L.strAddress		AS strEntityAddress,
			L.strCity			AS strEntityCity,
			L.strState			AS strEntityState,
			L.strZipCode		AS strEntityZipCode,
			L.strCountry		AS strEntityCountry,
			T.strPhone			AS strEntityPhone,
			E.intDefaultLocationId,
			CASE	WHEN Y.strType = 'Vendor' THEN V.ysnPymtCtrlActive 
					WHEN Y.strType = 'Customer' THEN U.ysnActive
					ELSE CAST(1 AS BIT)
			END	AS	ysnActive,
			CAST(ISNULL(S.intEntityId,0) AS BIT) ysnShipVia,
			CAST(ISNULL(V.intEntityVendorId	,0) AS BIT) ysnVendor,
			CASE	WHEN Y.strType = 'Vendor'	THEN	CASE WHEN TM.ysnActive = 1 THEN V.intTermsId ELSE NULL END
					WHEN Y.strType = 'Customer'	THEN	CASE WHEN TM.ysnActive = 1 THEN U.intTermsId ELSE NULL END
					ELSE L.intTermsId 
			END AS intTermId,
			V.strVendorAccountNum,
			CY.intCurrencyID	AS	intCurrencyId,
			CY.strCurrency,
			CY.ysnSubCurrency,
			MY.strCurrency		AS	strMainCurrency

	FROM	tblEMEntity				E
	CROSS
	APPLY	tblSMCompanyPreference	SC	
	JOIN	[tblEMEntityLocation]	L	ON	E.intEntityId			=	L.intEntityId 
										AND L.ysnDefaultLocation	=	1
	JOIN	[tblEMEntityType]		Y	ON	Y.intEntityId			=	E.intEntityId
	JOIN	[tblEMEntityToContact]	C	ON	C.intEntityId			=	E.intEntityId 
										AND C.ysnDefaultContact		=	1
	JOIN	tblEMEntity				T	ON	T.intEntityId			=	C.intEntityContactId	LEFT 
	JOIN	tblAPVendor				V	ON	V.intEntityVendorId		=	E.intEntityId			LEFT
	JOIN	tblARCustomer			U	ON	U.intEntityCustomerId	=	E.intEntityId			LEFT
	JOIN	(
				SELECT	EY.intEntityId 
				FROM	tblEMEntity			EY
				JOIN	[tblEMEntityType]	ET	ON	ET.intEntityId	=	EY.intEntityId	
												AND	ET.strType		=	'Ship Via'
			)						S	ON	S.intEntityId			=	E.intEntityId			LEFT
	JOIN	tblSMTerm				TM	ON TM.intTermID				=	CASE	WHEN Y.strType = 'Vendor'	THEN	V.intTermsId
																				WHEN Y.strType = 'Customer'	THEN	U.intTermsId
																				ELSE L.intTermsId 
																		END						LEFT
	JOIN	tblSMCurrency			CY	ON CY.intCurrencyID			=	CASE	WHEN Y.strType = 'Vendor'	THEN	ISNULL(V.intCurrencyId,SC.intDefaultCurrencyId)
																				WHEN Y.strType = 'Customer'	THEN	ISNULL(U.intCurrencyId,SC.intDefaultCurrencyId)
																				ELSE SC.intDefaultCurrencyId
																		END						LEFT
	JOIN	tblSMCurrency			MY	ON MY.intCurrencyID			=	CY.intMainCurrencyId	