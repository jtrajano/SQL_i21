CREATE FUNCTION [dbo].[fnSMParseJson_Item](@id int,@parent int, @start int,@json NVARCHAR(MAX),@parseName int)
RETURNS @hierarchy table(id int,parent int,name nvarchar(2000),kind nvarchar(10),ppos int,pend int,value nvarchar(MAX) NOT NULL)
AS
    BEGIN
        declare @kind   nvarchar(10)
        declare @name   nvarchar(MAX)=''
        declare @value  nvarchar(MAX)
        declare @p      int


        if (@parseName=1) begin
            select  @kind=kind,@name=name,@start=pend from dbo.fnSMParseJson_Name(@start,@json)
            if (@kind='ERROR') 
			begin
                insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(0,@parent,'','ERROR',@start,-1,@name)
                return
            end
        end
        set @kind=substring(@json,@start,1)
        set @start=dbo.fnSMJson_Skip(@json,@start)
        -- Handle strings

        if (@kind='"') begin
            select @value=value,@p=p2 from dbo.fnSMJson_String(@json,@start+1)
            if (@p=-1) begin
                insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,'','ERROR',@p,-1,isnull(@value,'Bad string'))
                return;
            end
            insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,@name,'STRING',@start,@p,@value)
            return
        end

        -- Handle Objects

        if (@kind='{') begin
            insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,@name,'OBJECT',@start,@start+1,'')
            insert into @hierarchy(id,parent,name,kind,ppos,pend,value) select id,parent,name,kind,ppos,pend,value from dbo.fnSMParseJson_Object(@id+1,@id,@start+1,@json)
			
            if exists(select * from @hierarchy where kind='ERROR') return

            select @p=max(pend) from @hierarchy
            set @start = dbo.fnSMJson_SkipUntil(@json,@p,'}')
            if (@start=0) begin
                insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,'','ERROR',@p,@p,'Expected [}] and have: '+dbo.fnSMParseJson_Message(@json,@p))
                return;
                end
            update @hierarchy set pend=@start where id=@id
            return
            end
			

        -- Handle Arrays

        if (@kind='[') begin
            insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,@name,'ARRAY',@start,@start+1,'')
            --insert into @hierarchy(id,parent,name,kind,ppos,pend,value) select id,parent,name,kind,ppos,pend,value from dbo.json_Array(@id+1,@id,@start+1,@json)

            declare @pos int,@m int,@b int=@start + 1, @parentArray int= @id, @arrayId int=@id +1 
			-- Look for first item after [
			set @pos=dbo.fnSMJson_Skip(@json,@start + 1)
			if (@pos = 0) begin
				if (right(@json,1)=']') return -- If found because this is an empty array then do not raise an error
				insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@arrayId,@parentArray,'','ERROR',@start + 1,-1,'Wrong array definition')
				return
				end
			-- If is ] then we have an empty array, lets return
			if (substring(@json,@pos,1)=']') return

			declare @hierarchy2 table
			(
			  id int,parent int,name nvarchar(2000),kind nvarchar(10),ppos int,pend int,value nvarchar(MAX) NOT NULL
			)

			-- Enter endless loop
			while (1=1) begin
				-- Insert item into hierarchy
				insert into @hierarchy2(id,parent,name,kind,ppos,pend,value) select id,parent,name,kind,ppos,pend,value from [dbo].[fnSMParseJson_Item](@arrayId,@parentArray,@pos,@json,0)


				-- If nothing was inserted then return
				if not exists(select * from @hierarchy) begin
						insert into @hierarchy2(id,parent,name,kind,ppos,pend,value) values(0,0,'','ERROR',@pos,-1,'Unexpected error')
						break
						end
				-- If an error happened then return
				if exists(select * from @hierarchy2 where kind='ERROR') break
				-- Get MAX id of inserted objects and ADD 1. This sets the new ID
				select @arrayId=max(id)+1 from @hierarchy2
				-- Get latest position of readed object
				select @m=max(pend) from @hierarchy2
				-- Skip after
				set @pos = dbo.fnSMJson_Skip(@json,@m)
				-- If we do not have a [,] then exit loop
				if (substring(@json,@pos,1)!=',') break
				-- Move after ,
				set @pos = dbo.fnSMJson_Skip(@json,@pos+1)
				end

			insert into @hierarchy(id,parent,name,kind,ppos,pend,value) select id,parent,name,kind,ppos,pend,value from @hierarchy2
	
			
			if exists(select * from @hierarchy where kind='ERROR') return

            select @p=max(pend) from @hierarchy
            set @start = dbo.fnSMJson_SkipUntil(@json,@p,']')

            if (@start=0) begin
                insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,'','ERROR',@p,@p,'Expected []] and have: '+dbo.fnSMParseJson_Message(@json,@p))
                return;
                end
            update @hierarchy set pend=@start where id=@id
            return
            end

        -- Handle NUmbers
        if (@kind='-' or (@kind>='0' and @kind<='9')) begin
            select @p=p2,@value=value from dbo.fnSMParseJson_Number(@json,@start)
            if (@p=-1) begin
                    insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,'','ERROR',@p,-1,isnull(@value,'Bad number'))
                    return;
                end
                insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,@name,'NUMBER',@start,@p,@value)
            return
        end

        -- Handle TRUE
        if (upper(substring(@json,@start,4))='TRUE') begin
                insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,@name,'BOOL',@start,@start+4,'1')
                return
        end

        -- Handle FALSE
        if (upper(substring(@json,@start,5))='FALSE') begin
                insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(@id,@parent,@name,'BOOL',@start,@start+5,'0')
                return
        end

        insert into @hierarchy(id,parent,name,kind,ppos,pend,value) values(0,@parent,@name,'ERROR',@start,@start,'Unexpected token '+@kind)

		
        return
end
