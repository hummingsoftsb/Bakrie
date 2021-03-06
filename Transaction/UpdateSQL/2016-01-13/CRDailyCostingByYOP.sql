
/****** Object:  StoredProcedure [Checkroll].[CRDailyCostingByKHTKHLReport]    Script Date: 13/1/2016 10:50:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
    
Create procedure [Checkroll].[CRDailyCostingByYOPorField]      
      
@EstateID nvarchar(50),      
@FromDate Date,      
@Todate Date,      
@ActiveMonthYearID nvarchar(50),      
@Amonth int,      
@AYear int,
@YOP nvarchar(50),
@FieldNo nvarchar(50)
  
AS      

BEGIN
	DECLARE @ActiveMonthYearIDST nvarchar(50)      
	SELECT @ActiveMonthYearIDST =ActiveMonthYearID  FROM  General .ActiveMonthYear G_AMY WHERE AMonth =@Amonth AND AYear =@AYear  AND ModID =2 AND EstateID =@EstateID      
	      
IF @FieldNo = '' 
bEGIN
	SELECT       
			 C_DAD.DailyDistributionID ,       
			 Checkroll.ConcatenateActivityCOA(A_COA.COAID) as Activity,          
			 SUBSTRING( A_COA.COACode, 1, 8) AccountCode,      
			 A_COA.COACode,      
			 G_YOP.YOP,      
			 C_DAD.DistbDate,      
			 G_BM.BlockName,      
			 CASE WHEN G_DIV .DivName IS NULL      
			   THEN 'NoDIV'      
			   ELSE      
			   G_DIV .DivName      
			 END AS DivName ,      
			       
			 ISNULL(C_DAD.Ha, 0) AS Ha,      
			 ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) ) as  Mandays,    
			  
			 case when C_GM.Category = 'KHL' then   
			 ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) ) *   Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) --(select ISNULL(StandardRate, 0) from CheckRoll.StandardRateSetup)    
			 else   
			 ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) ) *   Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) End as Salary,    
			 S_MASTER.StockDesc AS MaterialDesc,      
			 ISNULL(C_AMU.UsageQty, 0)AS MaterialQty,      
			 (SELECT Checkroll.CRDailyCosting( @EstateID,C_AMU.StockID,@ActiveMonthYearIDST)) AS AvgPrice,      
			 CASE      
			  WHEN C_DAD.Ha IS NULL or C_DAD.Ha = 0 THEN 0      
			  ELSE      			  
			  case when C_GM.Category = 'KHL' then     
			  ( ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) )  *  Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) ) / C_DAD.Ha      
			  else     
			  ( ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) )  *  Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) ) / C_DAD.Ha End     
			     
			 END AS SalaryPerHa      
			      
			FROM      
			Checkroll.DailyActivityDistribution AS C_DAD      
			LEFT JOIN General.Division AS G_DIV ON C_DAD.DIVID = G_DIV.DivID      
			INNER JOIN Accounts.COA AS A_COA ON C_DAD.COAID = A_COA.COAID      
			LEFT JOIN General.YOP AS G_YOP ON C_DAD.YOPID = G_YOP.YOPID      
			LEFT JOIN General.BlockMaster AS G_BM ON C_DAD.BlockID = G_BM.BlockID      
			INNER JOIN Checkroll.GangMaster As C_GM ON C_DAD.GangMasterID = C_GM.GangMasterID      
			LEFT JOIN Checkroll.ActivityMaterialUsage AS C_AMU ON C_DAD.DailyDistributionID = C_AMU.DailyDistributionID      
			LEFT JOIN Store.STMaster AS S_MASTER ON C_AMU.StockID = S_MASTER.StockID      
			      
			WHERE --C_GM.Category ='KHT' and 
			C_DAD.ActiveMonthYearID =@ActiveMonthYearID AND C_DAD .EstateID = @EstateID        
			      AND C_DAD.DistbDate BETWEEN @FromDate AND @Todate  
				  And G_YOP.YOP = @YOP         
			ORDER BY DistbDate, Activity
		END
ELSE
	BEGIN
			SELECT       
			 C_DAD.DailyDistributionID ,       
			 Checkroll.ConcatenateActivityCOA(A_COA.COAID) as Activity,          
			 SUBSTRING( A_COA.COACode, 1, 8) AccountCode,      
			 A_COA.COACode,      
			 G_YOP.YOP,      
			 C_DAD.DistbDate,      
			 G_BM.BlockName,      
			 CASE WHEN G_DIV .DivName IS NULL      
			   THEN 'NoDIV'      
			   ELSE      
			   G_DIV .DivName      
			 END AS DivName ,      
			       
			 ISNULL(C_DAD.Ha, 0) AS Ha,      
			 ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) ) as  Mandays,    
			  
			 case when C_GM.Category = 'KHL' then   
			 ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) ) *   Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) --(select ISNULL(StandardRate, 0) from CheckRoll.StandardRateSetup)    
			 else   
			 ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) ) *   Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) End as Salary,    
			 S_MASTER.StockDesc AS MaterialDesc,      
			 ISNULL(C_AMU.UsageQty, 0)AS MaterialQty,      
			 (SELECT Checkroll.CRDailyCosting( @EstateID,C_AMU.StockID,@ActiveMonthYearIDST)) AS AvgPrice,      
			 CASE      
			  WHEN C_DAD.Ha IS NULL or C_DAD.Ha = 0 THEN 0      
			  ELSE      			  
			  case when C_GM.Category = 'KHL' then     
			  ( ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) )  *  Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) ) / C_DAD.Ha      
			  else     
			  ( ( ISNULL(C_DAD.Mandays, 0) + (ISNULL(C_DAD.OT, 0)/7) )  *  Checkroll.GetTeamActualDailyRate(C_GM.GangMasterID,C_DAD.DistbDate) ) / C_DAD.Ha End     
			     
			 END AS SalaryPerHa      
			      
			FROM      
			Checkroll.DailyActivityDistribution AS C_DAD      
			LEFT JOIN General.Division AS G_DIV ON C_DAD.DIVID = G_DIV.DivID      
			INNER JOIN Accounts.COA AS A_COA ON C_DAD.COAID = A_COA.COAID      
			LEFT JOIN General.YOP AS G_YOP ON C_DAD.YOPID = G_YOP.YOPID      
			LEFT JOIN General.BlockMaster AS G_BM ON C_DAD.BlockID = G_BM.BlockID      
			INNER JOIN Checkroll.GangMaster As C_GM ON C_DAD.GangMasterID = C_GM.GangMasterID      
			LEFT JOIN Checkroll.ActivityMaterialUsage AS C_AMU ON C_DAD.DailyDistributionID = C_AMU.DailyDistributionID      
			LEFT JOIN Store.STMaster AS S_MASTER ON C_AMU.StockID = S_MASTER.StockID      
			      
			WHERE --C_GM.Category ='KHT' and 
			C_DAD.ActiveMonthYearID =@ActiveMonthYearID AND C_DAD .EstateID = @EstateID        
			      AND C_DAD.DistbDate BETWEEN @FromDate AND @Todate  
				  And G_BM.BlockName = @FieldNo        
			ORDER BY DistbDate, Activity

	END
END
