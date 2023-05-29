CREATE FUNCTION dbo.[fnAPGetYear1099](@type int, @vendorFrom NVARCHAR(50), @vendorTo NVARCHAR(50))
RETURNS @Result TABLE(strYear NVARCHAR(10), intType INT)
AS
BEGIN
    IF @type = 1
        INSERT INTO @Result
        SELECT DISTINCT CAST(intYear AS NVARCHAR(10)), @type FROM vyuAP1099MISCYear
        WHERE 1 = (CASE WHEN @vendorFrom != 'null' THEN
                    (CASE WHEN strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
                ELSE 1 END)
        ORDER BY 1 DESC
    ELSE IF @type = 2
        INSERT INTO @Result
        SELECT DISTINCT CAST(intYear AS NVARCHAR(10)), @type FROM vyuAP1099INTYear
        WHERE 1 = (CASE WHEN @vendorFrom != 'null' THEN
                    (CASE WHEN strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
                ELSE 1 END)
        ORDER BY 1 DESC
    ELSE IF @type = 3
        INSERT INTO @Result 
        SELECT DISTINCT CAST(intYear AS NVARCHAR(10)), @type FROM vyuAP1099BYear
        WHERE 1 = (CASE WHEN @vendorFrom != 'null' THEN
                    (CASE WHEN strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
                ELSE 1 END)
        ORDER BY 1 DESC
    ELSE IF @type = 4
        INSERT INTO @Result 
        SELECT DISTINCT CAST(intYear AS NVARCHAR(10)), @type FROM vyuAP1099PATRYear
        WHERE 1 = (CASE WHEN @vendorFrom != 'null' THEN
                    (CASE WHEN strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
                ELSE 1 END)
        ORDER BY 1 DESC
    ELSE IF @type = 5
        INSERT INTO @Result
        SELECT DISTINCT CAST(intYear AS NVARCHAR(10)), @type FROM vyuAP1099DIVYear
        WHERE 1 = (CASE WHEN @vendorFrom != 'null' THEN
                    (CASE WHEN strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
                ELSE 1 END)
        ORDER BY 1 DESC
    ELSE IF @type = 6
        INSERT INTO @Result 
        SELECT DISTINCT CAST(intYear AS NVARCHAR(10)), @type FROM vyuAP1099KYear
        WHERE 1 = (CASE WHEN @vendorFrom != 'null' THEN
                    (CASE WHEN strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
                ELSE 1 END)
        ORDER BY 1 DESC
    ELSE IF @type = 7
        INSERT INTO @Result
        SELECT DISTINCT CAST(intYear AS NVARCHAR(10)), @type FROM vyuAP1099NEC
        WHERE 1 = (CASE WHEN @vendorFrom != 'null' THEN
                    (CASE WHEN strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
                ELSE 1 END)
        ORDER BY 1 DESC

    RETURN;
END