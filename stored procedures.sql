select * from [dbo].[tblemployee]
create proc sptolu
@age int,
@name nvarchar(20)

as
begin
select gender,id from [dbo].[tblemployee] where name= @name and salary =@age
end

exec sptolu 5000,'kemi'