CREATE FUNCTION dbo.fnARSplitValues(@String varchar(8000), @Delimiter char(1))       
RETURNS @temptable TABLE (strDataType varchar(8000))       
AS       
BEGIN       
    declare @idx int       
    declare @slice varchar(8000)       

    select @idx = 1       
        if len((dbo.fnARRemoveSpecialChars(@String)))<1 or @String is null  return       

    while @idx!= 0       
    begin       
        set @idx = charindex(@Delimiter,dbo.fnARRemoveSpecialChars(@String))       
        if @idx!=0       
            set @slice = left(dbo.fnARRemoveSpecialChars(@String),@idx - 1)       
        else       
            set @slice = dbo.fnARRemoveSpecialChars(@String)       

        if(len(@slice)>0)  
            insert into @temptable(strDataType) values(@slice)  
			     

        set @String = right(@String,len(dbo.fnARRemoveSpecialChars(@String)) - @idx)       
        if len(dbo.fnARRemoveSpecialChars(@String)) = 0 break       
    end   
RETURN       
END  