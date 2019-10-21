CREATE VIEW [dbo].[vyuBBBubacksProgramInvoices]
AS
SELECT DISTINCT strVendorNumber = (E.strEntityNo)
    , strVendorName = (E.strName)
    , strCustomerLocation = (F.strLocationName)
    , strCustomerId = (D.strVendorSoldTo)
    , strInvoiceNumber = (A.strInvoiceNumber)
    , dtmShipDate = (A.dtmShipDate)
    , intEntityId = (C.intEntityId)
    , M.intProgramId
FROM tblARInvoice A
INNER JOIN tblARInvoiceDetail B
    ON A.intInvoiceId = B.intInvoiceId
INNER JOIN tblVRVendorSetup C
    ON A.intEntityCustomerId = C.intEntityId
INNER JOIN tblBBCustomerLocationXref D
    ON A.intShipToLocationId = D.intEntityLocationId
        AND C.intVendorSetupId = D.intVendorSetupId
INNER JOIN tblEMEntity E
    ON C.intEntityId = E.intEntityId
INNER JOIN tblEMEntityLocation F
    ON D.intEntityLocationId = F.intEntityLocationId
INNER JOIN tblICItem G
    ON B.intItemId = G.intItemId
INNER JOIN tblICCategory H
    ON G.intCategoryId = H.intCategoryId
INNER JOIN tblICItemUOM I
    ON B.intItemUOMId = I.intItemUOMId
INNER JOIN tblICUnitMeasure J
    ON I.intUnitMeasureId = J.intUnitMeasureId
INNER JOIN tblBBProgram M
    ON C.intVendorSetupId = M.intVendorSetupId
INNER JOIN tblBBProgramCharge N
    ON M.intProgramId = N.intProgramId
GO
