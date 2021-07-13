create database Quan_ly_quan_cafe
use Quan_ly_quan_cafe
go
create table tablefood
(
id INT IDENTITY PRIMARY KEY,
name NVARCHAR(100),
status NVARCHAR(100) DEFAULT N'Trống', --TRONG || CO NGUOI
)

create table Account
(
usename NVARCHAR(100) PRIMARY KEY,
displayname NVARCHAR(100),
passwork NVARCHAR(100) DEFAULT 0,
type INT DEFAULT 0,-- 0 LA ADMIN , 1 LA STAFF
)
create table foodcategory
(
id INT IDENTITY PRIMARY KEY,
name NVARCHAR(100) DEFAULT N'Chưa đặt tên',
)
create table food
(
id INT IDENTITY PRIMARY KEY,
name NVARCHAR(100) DEFAULT N'Chưa đặt tên',
idcategory INT,
price FLOAT DEFAULT 0,
Foreign key (idcategory) references foodcategory(id),
)
create table bill
(
id INT IDENTITY PRIMARY KEY,
datecheckin DATE DEFAULT GETDATE(),
datecheckout DATE,
idtable INT,
status INT DEFAULT 0,
FOREIGN KEY (idtable) REFERENCES tablefood(id)
)
create table billinfo
(
id INT IDENTITY PRIMARY KEY,
idbill INT,
idfood INT,
count INT DEFAULT 0,
Foreign key (idbill) references  bill(id),
Foreign key (idfood)references food(id),
)
insert into Account values 
('Admin','Admin','123456',1),
('Staff','Staff','111111',0)

SELECT*FROM Account

alter PROC USP_GetAccountByUseName
@usename nvarchar(100)
AS 
BEGIN
SELECT*FROM Account WHERE usename=@usename
END
exec USP_GetAccountByUseName @usename='Admin'
go


create proc USP_Login
@usename nvarchar(100),@passwork nvarchar(100)
as
begin
select*from Account where usename=@usename and passwork=@passwork
end
go
declare @i int =0
while @i<=10
begin
insert into tablefood(name) values
(N'Bàn'+ CAST(@i as nvarchar(100)))
set @i=@i+1
end
go


create proc GetTableList
as
Select*from tablefood
exec GetTableList

update tablefood set tablefood.status= N'Có người' where id=10
go
insert into foodcategory(name) values
(N'Cà phê'),
(N'Sinh tố')
go
insert into food values
(N'Cafe Sữa',1,30000),
(N'Latte',1,35000),
(N'Cappuccino',1,25000),
(N'Expresso',1,28000),
(N'Cafe mocha',1,20000),
(N'Americano',1,38000),
(N'Sinh tố Xoài',2,20000),
(N'Sinh tố dứa',2,25000),
(N'Sinh tố chuối',2,20000),
(N'Sinh tố bơ',2,23000)
go
insert into Bill(datecheckin,datecheckout,idtable,status,discount) values
(getdate(),null, 1,0,0),
(getdate(),getdate(), 2,1,0),
(getdate(),null, 3,0,0)
go
insert into billinfo values
(25,5,2),
(26,9,2)

alter proc InsertBill 
@idTable Int
as
begin
insert  bill values
(Getdate(),null,@idTable,0,0,null)
end

alter proc InsertBillInfo
@idBill int , @idfood int ,@count int
as
begin
  declare @isexitsbillinfo int;
  declare @foodcount int=1;
  select @isexitsbillinfo= id,@foodcount=count from billinfo Where idbill =@idBill and idfood=@idfood
  if(@isexitsbillinfo>0)
  begin
    declare @newcount int =@foodcount+@count
    if(@newcount>0)
       update billinfo set count =@foodcount+@count where idfood=@idfood
    else
       Delete billinfo where idbill=@idBill and idfood =@idfood 
  end
  else
  begin
     insert billinfo values 
     (@idBill,@idfood,@count)
  end
end

alter trigger updatebillinfo on billinfo for insert,update
as
begin
declare @idbill int
select @idbill=idbill from inserted
declare @idtable int
select @idtable=idtable from bill where id = @idbill and status=0
update tablefood set status=N'Có người' where id = @idtable
end

alter trigger updatebill on bill for update 
as
begin 
declare @idbill int
select @idbill=id from inserted
declare @idtable int
select @idtable=idtable from bill where id=@idbill 
declare @count int =0
select @count=count(*) from bill where idtable=@idtable and status=0
if(@count=0)
update tablefood set status =N'Trống' where id=@idtable

end

alter table bill add totalprice  float

alter proc GetListBillByDate
@checkin date,@checkout date
as
begin

select Tablefood.name as [Tên bàn],bill.totalprice as [Tổng tiền], datecheckin as [Ngày vào], datecheckout as [Ngày ra], discount as [Giảm giá]
from bill, tablefood
where datecheckin>=@checkin and datecheckout<=@checkout and bill.status=1 and
tablefood.id=bill.idtable 
end

create proc UpdateAccount
@usename nvarchar(100), @displayname nvarchar(100), @passwork nvarchar(100),@newpasswork nvarchar(100)
as
begin
	declare @isrightpass int = 0
	select @isrightpass=count(*) from Account where usename=@usename and passwork =@passwork
	if(@isrightpass=1)
	begin
		if(@newpasswork=null or @newpasswork ='')
			begin
			update Account set displayname=@displayname where usename=@usename
			end
		else
			update Account set displayname=@displayname,passwork=@newpasswork where usename=@usename
	end
end


update food set name =N'', idcategory =5,price =0 where id=8


alter trigger DeleteBillInfo on BillInfo for delete as
begin
declare @idbill int
declare @idbillinfo int
select @idbillinfo = id,@idbill=deleted.idbill from DELETED

declare @idtable int
select @idtable=idtable from bill where id=@idbill
declare @count int =0
select @count =count(*) from BillInfo, Bill where bill.id=billinfo.idbill and Bill.id=@idbill and Bill.status=0
if(@count=0)
update tablefood set status =N'Trống' where id= @idtable
end


select*from food where dbo.non_unicode_convert(name) like N'%dua%'
delete bill
Delete Account where usename =N'Tester'
select max(id) from bill
 select food.name,billinfo.count,food.price,billinfo.count*food.price as Totalprice from food,billinfo,bill
 where food.id=billinfo.idfood and bill.id=billinfo.idbill and idtable=3
select*from food
select*from foodcategory
select*from Tablefood
select*from bill 
select*from billinfo 
select*from Account

-- loc dau
CREATE FUNCTION [dbo].[non_unicode_convert](@inputVar NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
AS
BEGIN    
    IF (@inputVar IS NULL OR @inputVar = '')  RETURN ''
   
    DECLARE @RT NVARCHAR(MAX)
    DECLARE @SIGN_CHARS NCHAR(256)
    DECLARE @UNSIGN_CHARS NCHAR (256)
 
    SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệếìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵýĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ' + NCHAR(272) + NCHAR(208)
    SET @UNSIGN_CHARS = N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooouuuuuuuuuuyyyyyAADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD'
 
    DECLARE @COUNTER int
    DECLARE @COUNTER1 int
   
    SET @COUNTER = 1
    WHILE (@COUNTER <= LEN(@inputVar))
    BEGIN  
        SET @COUNTER1 = 1
        WHILE (@COUNTER1 <= LEN(@SIGN_CHARS) + 1)
        BEGIN
            IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1)) = UNICODE(SUBSTRING(@inputVar,@COUNTER ,1))
            BEGIN          
                IF @COUNTER = 1
                    SET @inputVar = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)-1)      
                ELSE
                    SET @inputVar = SUBSTRING(@inputVar, 1, @COUNTER-1) +SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)- @COUNTER)
                BREAK
            END
            SET @COUNTER1 = @COUNTER1 +1
        END
        SET @COUNTER = @COUNTER +1
    END
    -- SET @inputVar = replace(@inputVar,' ','-')
    RETURN @inputVar
END
