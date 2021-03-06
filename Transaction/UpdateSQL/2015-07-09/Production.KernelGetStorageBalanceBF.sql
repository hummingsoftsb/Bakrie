
/****** Object:  StoredProcedure [Production].[KernelGetStorageBalanceBF]    Script Date: 9/7/2015 1:07:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [Production].[KernelGetStorageBalanceBF]

	-- Add the parameters for the stored procedure here
	
	@EstateID nvarchar(50),
	@ProductionDate as Date,
	@CropYieldID nvarchar(50),
	@KernelStorageID Nvarchar(50)
	
	
		
AS			
			Declare @BalanceBf as numeric(18,3)=0 
						
			--Select 
			--@BalanceBf = CPO_Stock .CurrentReading - Isnull(DP2.TotalDispatch,0)
			--from Production .CPOProduction CPO
			--Inner Join Production .CPOProductionStockCPO CPO_Stock ON CPO_Stock .ProductionID = CPO .ProductionID 
			--Inner Join Production .KernelStorage   P_TM ON CPO_Stock .KernelStorageID  = P_TM.KernelStorageID  
			--LEft join (select ISNull(Sum(MillWeight),0) as TotalDispatch,LoadingLocationID  from Production.CPODispatch DP  
			----WHERE DP.DispatchDate = DateAdd(d,-1,@ProductionDate) Group By LoadingLocationID) as DP2 on P_TM.Code = DP2.LoadingLocationID
			--WHERE DP.DispatchDate = @ProductionDate Group By LoadingLocationID) as DP2 on P_TM.Code = DP2.LoadingLocationID
			--where CPO .EstateID =@EstateID 
			----AND CPO.CPOProductionDate = DATEADD(day,-1,@ProductionDate)	
			--AND CPO.CPOProductionDate = @ProductionDate
			--AND CPO .CropYieldID = @CropYieldID 
			--AND P_TM .KernelStorageID = @KernelStorageID 
				
			--if @BalanceBf = 0 
			--Select top 1
			--	CPO_Stock .CurrentReading as BalanceBF  
			--	from Production .CPOProduction CPO
			--	Inner Join Production .CPOProductionStockCPO CPO_Stock ON CPO_Stock .ProductionID = CPO .ProductionID 
			--	Inner Join Production .KernelStorage   P_TM ON CPO_Stock .KernelStorageID  = P_TM.KernelStorageID  
			--	where CPO .EstateID =@EstateID 
			--	AND CPO.CPOProductionDate < @ProductionDate	
			--	AND CPO .CropYieldID = @CropYieldID 
			--	AND P_TM .KernelStorageID = @KernelStorageID 
			--	order by CPO .Id Desc
			--else
--				Select @BalanceBf as BalanceBF

	
			Select BFQTY as BalanceBF From Production.KernelStorage KS where KS.KernelStorageID  = @KernelStorageID
			
			Select 
			ISNULL(SUM(CPO_Load .CurrentQty),0)  as PontoonPrevQty  
			from Production .CPOProduction CPO
			Inner Join Production .CPOProductionLoad  CPO_Load ON CPO_Load .ProductionID = CPO .ProductionID 
			where CPO .EstateID =@EstateID 
			--AND CPO.CPOProductionDate = DATEADD (Day,-1, @ProductionDate)
			AND CPO.CPOProductionDate = DATEADD (Day,-1, @ProductionDate)
			AND CPO .CropYieldID = @CropYieldID 












