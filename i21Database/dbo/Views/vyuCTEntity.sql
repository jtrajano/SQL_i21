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
			L.intEntityLocationId	AS	 intDefaultLocationId,
			L.strLocationName	AS	strDefaultLocation,
			CASE	WHEN Y.strType IN('Vendor','Shipping Line','Producer') THEN V.ysnPymtCtrlActive 
					WHEN Y.strType = 'Customer' THEN U.ysnActive
					WHEN Y.strType = 'Salesperson' THEN P.ysnActive
					ELSE E.ysnActive
			END	AS	ysnActive,
			CAST(ISNULL(S.intEntityId,0) AS BIT) ysnShipVia,
			CAST(ISNULL(V.intEntityId,0) AS BIT) ysnVendor,
			intTermId = TM.intTermID,
			strTerm = TM.strTerm,
			V.strVendorAccountNum,
			CY.intCurrencyID	AS	intCurrencyId,
			CY.strCurrency,
			CY.ysnSubCurrency,
			MY.strCurrency		AS	strMainCurrency,
			ISNULL(V.strFLOId,U.strFLOId) AS strFLOId

	FROM	tblEMEntity				E
	CROSS APPLY	(SELECT TOP 1 * FROM tblSMCompanyPreference) SC	
	LEFT JOIN	[tblEMEntityLocation]	L	ON	E.intEntityId			=	L.intEntityId 
											AND L.ysnDefaultLocation	=	1
	LEFT JOIN	[tblEMEntityType]		Y	ON	Y.intEntityId			=	E.intEntityId
	LEFT JOIN	[tblEMEntityToContact]	C	ON	C.intEntityId			=	E.intEntityId 
											AND C.ysnDefaultContact		=	1
	LEFT JOIN	tblEMEntity				T	ON	T.intEntityId			=	C.intEntityContactId	 
	LEFT JOIN	tblAPVendor				V	ON	V.intEntityId			=	E.intEntityId			
	LEFT JOIN	tblARCustomer			U	ON	U.intEntityId			=	E.intEntityId					
	LEFT JOIN	tblARSalesperson		P	ON	P.intEntityId			=	E.intEntityId
	OUTER APPLY (
		SELECT	EY.intEntityId 
		FROM	tblEMEntity EY INNER JOIN tblEMEntityType ET
					ON EY.intEntityId = ET.intEntityId
		WHERE	EY.intEntityId = E.intEntityId	
				AND	ET.strType = 'Ship Via'
	) S	
				
	OUTER APPLY (
		SELECT  TM.intTermID, TM.strTerm 
		FROM	tblSMTerm TM
				OUTER APPLY (
					SELECT	intTermID, ysnActive
					FROM	tblSMTerm 
					WHERE	intTermID = V.intTermsId
							AND Y.strType = 'Vendor'
							AND ysnActive = 1				
				) vendorTerm
				OUTER APPLY (
					SELECT	intTermID, ysnActive
					FROM	tblSMTerm 
					WHERE	intTermID = U.intTermsId
							AND Y.strType = 'Customer'
							AND ysnActive = 1				
				) customerTerm 
				OUTER APPLY (
					SELECT	intTermID, ysnActive
					FROM	tblSMTerm 
					WHERE	intTermID = L.intTermsId 
							AND Y.strType NOT IN ('Vendor', 'Customer') 
							AND ysnActive = 1				
				) defaultTerm
		WHERE	TM.intTermID = COALESCE(vendorTerm.intTermID, customerTerm.intTermID, defaultTerm.intTermID)
	) TM 
	OUTER APPLY (
		SELECT	CY.intCurrencyID, CY.strCurrency, CY.ysnSubCurrency, CY.intMainCurrencyId				
		FROM	tblSMCurrency CY 
				OUTER APPLY (
					SELECT	intCurrencyID
					FROM	tblSMCurrency 
					WHERE	intCurrencyID = V.intCurrencyId
							AND Y.strType = 'Vendor'
				) vendorCurrency
				OUTER APPLY (
					SELECT	intCurrencyID
					FROM	tblSMCurrency 
					WHERE	intCurrencyID = U.intCurrencyId
							AND Y.strType = 'Customer'
				) customerCurrency
				OUTER APPLY (
					SELECT	intCurrencyID
					FROM	tblSMCurrency 
					WHERE	intCurrencyID = SC.intDefaultCurrencyId
							AND Y.strType NOT IN ('Vendor', 'Customer')
				) defaultCurrency
		WHERE	CY.intCurrencyID = COALESCE(vendorCurrency.intCurrencyID, customerCurrency.intCurrencyID, defaultCurrency.intCurrencyID)
	) CY 	
	LEFT JOIN	tblSMCurrency			MY	ON MY.intCurrencyID			=	CY.intMainCurrencyId		
