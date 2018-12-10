-----1)creer une fonction scalaire qui retourne le nombre total de clients ayant
--passer une commande



Create Function  Nbtotal_Client ()
RETURNS int 
AS
BEGIN; 
declare @val int;
 set @val=(Select Count(Distinct O.CustomerID) From Orders O);

Return @val ;
END;
khjkgjghjgjfgjfgfgjhghg

Select dbo.Nbtotal_Client() as TotaClient ;

--2)creer une fonction scalaire qui retourne pour chaque client donné le nombre de ces commandes

CREATE FUNCTION nbcom_Client1( @CustomersId nchar(5))
RETURNS int 
AS
BEGIN;
 declare @nbr int ;
  set @nbr= (Select count (O.OrderID) From Orders O 
 where CustomerID= @CustomersId)

 RETURN  @nbr;
 END;

 SELECT dbo.nbcom_Client1('AlFKI') as nombreCom;
--3)creer une fonction scalaire qui retourne pour chaque client donné  sa premiere date de commande

CREATE FUNCTION  DateCom(@Client nchar(5))
RETURNS datetime
AS
BEGIN;
declare @date datetime;
 set @date =(select top 1  O.OrderDate from  Orders O
  WHERE   CustomerID=@Client order by OrderDate asc);
  RETURN  @date;
 END;
 SELECT dbo.DateCom('AlFKI') as datecom;

 --------  pour chaque client donné  sa premiere date de commande


Select distinct CustomerID ,dbo.DateCom(CustomerID) as datcommande
from Orders;

---Creer une fonction qui commense par com et 5chiffre
--solution 

ALter  FUNCTION Com_chiffre3(@val int)
RETURNS nvarchar (8)
As
BEGIN;
declare @comm nchar;
set @comm = REPLICATE('0',5-LEN(@val))

 RETURN  'COM'+@comm+cast(@val as nvarchar(5)) ;
END;

Select dbo.Com_chiffre3(10) as resultat; 

		Select Distinct OrderID, dbo.Com_chiffre3(OrderID)  From Orders

----Creer une fonction qui retourne pour chaque client donner ces 3derniers commandes
--les plus recentes

Alter FUNCTION CommRecente1(@CustomersId nchar(5))
 RETURNS TABLE
  AS
  RETURN(select top 3 OrderDate,CustomerID From 
  Orders  Where CustomerID =@CustomersId order   by OrderDate desc);

  go

  SElect * from dbo.CommRecente1('ALFKI')as recent3;
  go

  SElect * from dbo.CommRecente1('ALFKI') 
  go


  declare @table_custormerID TABLE(id int identity(1,1),customerid nchar(5))
  insert into @table_custormerID
  select distinct customerid from Orders

 declare @val int
 declare @compteur int,@customer nchar(5) 
 set @val =1
 set @compteur=(select count (*) from @table_custormerID)
  while(@val<=@compteur)
  begin 
  set @customer= (select customerid from @table_custormerID where id =@val)

   declare @tab TABLE(id int identity(1,1),OrderDate Datetime,customerid nchar(9))
  insert into @tab
  select * from dbo.CommRecente1(@customer)
   set @val=@val+1
 end

   select * from @tab;
   go 

   -----fonction commanderecente
   CREATE FUNCTION ComRecentes(@CustomersId nchar(10))
    returns @TableCom TABLE(id int identity(1,1),customerid nchar(5),OrderDate Datetime)
	 AS
	 begin
   insert into @TableCom select top 3 CustomerID, OrderDate From 
  Orders  Where CustomerID = @CustomersId order   by OrderDate desc
  return;
  end
  go

  SELECT * from dbo.ComRecentes('ALFKI')
   
    -----fonction commanderecente avec update
   CREATE FUNCTION ComRecentesavecUpdate(@CustomersId nchar(10))
    returns @TableCom1 TABLE(id int identity(1,1),orderid int ,customerid nchar(5),OrderDate Datetime)
	 AS
	 begin 
   insert into @TableCom1 select top 3  OrderID,CustomerID, OrderDate From 
  Orders O Where O.CustomerID = @CustomersId order   by OrderDate desc
 Update @TableCom1 set orderid =orderid+1000
  return;
  end
  go
   SELECT * from dbo.ComRecentesavecUpdate('ALFKI')


   --Sélectionner le nom des clients et le nom des produits, pour
  --- les clients qui ont acheté de ce produit 5 fois plus que la moyenne des ventes 

   alter  Procedure  Moyenne5produit @produitid nchar(5)
   as
   declare @moyenVenteP float
    set @moyenVenteP=(Select  AVG(Quantity) from[Order Details] OD
	where OD.ProductID=@produitid)
   SElect CustomerID,sum( Quantity) From Orders O
   inner join [Order Details] OD ON OD.OrderID = O.OrderID
		where productid =@produitid
		Group by CustomerID
		having (sum( Quantity) ) > 5 *  @moyenVenteP
		print 'moyenne' +@produitid+ ' est : '  +cast(@moyenVenteP as nchar)
		go


 exec Moyenne5produit 52

----mm question avec fonction table

 -----fonction commanderecente
   alter  FUNCTION  moyenneVente(@produitid nchar(5))
    returns @TableVenteMoy  TABLE(id int identity(1,1),customerid nchar(5),productid int)
	 AS
 begin
	  declare @moyenVenteP float;
	    set @moyenVenteP=( Select  AVG(Quantity) from[Order Details] OD
	where OD.ProductID=@produitid )
	 insert into @TableVenteMoy 
   SElect CustomerID,productid
   From Orders O
   inner join [Order Details] OD ON OD.OrderID = O.OrderID
		where productid =@produitid
		Group by CustomerID,productid
		having (count (Distinct productid)) > 5 *  @moyenVenteP

		return;
end
go

select * from dbo.moyenneVente(9)
go

--Sélectionner le nom des clients et le nom des produits, pour
  --- les clients qui ont acheté de ce produit 5 fois plus que la moyenne des ventes 

  select CustomerID,ProductID,sum( Quantity)  from Orders o
  inner join [Order Details] od on od.OrderID = o.OrderID
  group by  CustomerID,ProductID
  having sum( Quantity) >5* (select AVG(Quantity) from  [Order Details] od1
  where od1.ProductID = od.ProductID)




  





