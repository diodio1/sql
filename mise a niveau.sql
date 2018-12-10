
 --1)S�lectionner le nom des clients qui n'ont achet� aucun produit. Ecrire 2 versions de la requ�te : 
 --a. avec NOT IN 
  Select * from Customers Where CustomerID  NOT IN(Select CustomerID from Orders)
  --b. avec EXISTS 
   Select * from Customers C WHERE NOT  EXISTS (Select CustomerID from Orders O  Where O.CustomerID = C.CustomerID)
   --Test a l'interieur de la requete
   --avec Jointure 
   SELECT * FROM Customers C Left join Orders O ON O.CustomerID = C.CustomerID Where O.CustomerID IS NULL

   ---2)S�lectionner la liste des territoires o� il n�y a pas d�employ� affect� (utiliser une jointure
   Select * from  Territories T left join EmployeeTerritories ET  On T.TerritoryID =ET.TerritoryID Where 
   ET.TerritoryID IS NULL
 select * from EmployeeTerritories ET  right join  Territories T on T.TerritoryID = Et.TerritoryID where T.TerritoryID is null
   --3)Sp�cifier le nom des clients qui ont achet� tous les produits dont 
   --le prix unitaire est inf�rieur � 5 (ne pas utiliser de clause Group By) 

   SELECT * from Customers  C WHERE NOT EXISTS 
   (SELECT * FROM Products P where P.UnitPrice< 5 AND NOT EXISTS
 (Select * from Orders O inner join [Order Details] Od On O.OrderID = Od.OrderID Where Od.ProductID= P.ProductID 
 AND C.CustomerID = O.CustomerID))
 
 --- 4)Dans la table Order Details de la base Northwind, 
 --donner  pour les totaux supla quantit� totale par commande�rieurs � 300. 
 Select OrderID, SUM(Quantity)as TotalQ FROM [Order Details] GROUP BY  OrderID
   HAVING SUM(Quantity) > 300

-- 5)Sp�cifier le nom des clients qui ont achet� tous les produits dont le prix unitaire est inf�rieur � 5
-- (Utiliser  cette fois-ci la clause Group By avec Having) 

Select CustomerID , count (Distinct OD.ProductID) from Orders O INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
		INNER JOIN Products P ON P.ProductID = OD.ProductID 
		Where P.UnitPrice < 5 
		Group by (CustomerID) 
		Having Count (Distinct OD.ProductID )= (select  count ( ProductID) 
		from Products P1 Where P1.UnitPrice <5 )

----6)S�lectionner le nom des employ�s qui vendent les produits de plus de 5 fournisseurs.  
select EmployeeID , count ( Distinct P.SupplierID ) From Suppliers S Inner join Products P
	ON S.SupplierID = P.SupplierID  Inner join [Order Details] OD On OD.ProductID = P.ProductID
	Inner Join Orders O On O.OrderID = OD.OrderID 
	Group by EmployeeID 
	Having count ( Distinct P.SupplierID ) >5
	

	----10. Dans la base Northwind, 
	----lister les 5 commandes les plus r�centes pass�es par un client. 
	Select   top 5   * From Orders O  Order by O.OrderDate desc
	go 
	
	Create Procedure 
	totaux_quantit�_totale_par_commande_inf�rieurs_�_300 AS 
	Select OrderID, SUM(Quantity)as TotalQ FROM [Order Details] GROUP BY  OrderID
   HAVING SUM(Quantity) > 300
Go

Exec totaux_quantit�_totale_par_commande_inf�rieurs_�_300
go
Create Procedure Commande_REcents AS 
Select   top 5   * From Orders O  Order by O.OrderDate desc
Go
Exec Commande_REcents
GO

Create Procedure Nbre_client @CustomerID nchar(5) AS
Select CustomerID, count (*) from Orders O Where O.CustomerID= @CustomerID
Group by (CustomerID) 
Go
Exec  Nbre_client AlFKI
go

Create Procedure Nbre_com_client @CustomerID nchar(5) AS
declare @nombre int
set @nombre= (Select count (*) as nombre from Orders O Where O.CustomerID= @CustomerID)
Go
Exec  Nbre_com_client 'AlFKI'
go
---creer une procedure stocker qui renvoit la quantit� total command�e pour chaque client

alter Procedure Quantite_com1 @CustomersId nchar(5) as 
 declare @val int 
 set @val= (Select SUM(Quantity)as TotalQ FROM [Order Details] od inner join Orders O 
 on O.OrderID = od.OrderID
 where CustomerID= @CustomersId)
print 'la quantite total commande par  '+@CustomersId+ ' est : '  +cast(@val as nchar)
go

Exec Quantite_com1 'AlFKI'
go

---Procedure stocker qui renvoit le nombre total de commande ainsi que la quantite total
--command�e pour un client donne

Create Proc NbtotalCom_Quant1 @Costumerid nchar(5)
as  declare @nbr int,@valeur int
select @nbr= SUM(od.Quantity), @valeur = count(distinct od.OrderID ) from [Order Details] od 
   inner join Orders O on  O.OrderID = od.OrderID
 where CustomerID= @Costumerid
 print 'la quantite total commande par  '+@Costumerid+ ' est : '  +cast(@nbr as nchar)
print 'le nombre total de commande  '+@Costumerid+ ' est : '  +cast(@valeur as nchar)

go
 exec NbtotalCom_Quant1 'AlFKI'



 ---lister les 5 commandes les plus r�centes pass�es par un client. 
  create  Procedure  ComRecente_parclien @Costumerid nchar(5) as 
Select   top 5 O.CustomerID,O.OrderDate from  Orders O
Where O.CustomerID=@Costumerid
 Order by O.OrderDate desc 
  go
  exec  ComRecente_parclien 'AlFKI'
  go

  
   Select C.CustomerID from Customers C Where  EXISTS 
   (Select top 5 * from  Orders O Where O.CustomerID = C.CustomerID Order by O.OrderDate desc )


  ---S�lectionner le nom des clients et le nom des produits, pour
  --- les clients qui ont achet� de ce produit 5 fois plus que la moyenne des ventes 

   alter  Procedure  Moyenne5produit @produitid nchar(5)
   as
   declare @moyenVenteP float
    set @moyenVenteP=(Select  AVG(Quantity) from[Order Details] OD
	where OD.ProductID=@produitid)
   SElect CustomerID,count( Distinct productid) From Orders O
   inner join [Order Details] OD ON OD.OrderID = O.OrderID
		where productid =@produitid
		Group by CustomerID
		having (count (Distinct productid)) > 5 *  @moyenVenteP
		print 'moyenne' +@produitid+ ' est : '  +cast(@moyenVenteP as nchar)
		go


 exec Moyenne5produit 52

