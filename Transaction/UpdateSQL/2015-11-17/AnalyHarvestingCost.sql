
/****** Object:  StoredProcedure [Checkroll].[AnalyHarvestingCostInsert]    Script Date: 17/11/2015 9:35:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Created By		: Palani
-- Created Date		: 10-May-2011
-- Modified By		: Palani
-- Modified Date	: 30-June-2011
-- Modified By		: Stanley
-- Modified Date	: 03-Aug-2011 ~ 04-Aug-2011
-- Modified By		: Stanley
-- Modified Date	: 08-Sep-2011
-- Modified By		: Stanley
-- Modified Date	: 10-Oct-2011
-- Modified By		: Stanley
-- Modified Date	: 04-Nov-2011
-- Modified By		: Stanley
-- Modified Date	: 02-Dec-2011~04-Dec-2011
-- Description      : During Checkroll-Monthly Closing, records required for the Analysis Harvesting Cost Report is inserted into [AnalyHarvestingCost] table

ALTER PROCEDURE [Checkroll].[AnalyHarvestingCostInsert]

	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50),
	@CreatedBy nvarchar(50) 
	
AS

BEGIN
	Declare @Amonth int    
	Declare @Ayear int    
	Select @Amonth =Amonth, @Ayear =ayear from General.ActiveMonthYear where EstateID = @EstateID and ActiveMonthYearID = @ActiveMonthYearID    

	--stan@10-10-2011.a
	CREATE TABLE #DistCRPanen (
				Descript nVArChar(50),
				Descript2 nVArChar(50),
				YOP nVArChar(50),
				HK decimal(18,2),
				RpHK decimal(18,2),
				Jumlah decimal(18,2) )

	
    INSERT INTO #DistCRPanen 
	Select FinalTResult.Description, FinalTResult.Description2, FinalTResult.YOP, SUM(FinalTResult.AktualHK) as AktualHK,
	SUM(FinalTResult.RpHK), SUM(FinalTResult.Jumlah)
	from 
	( 
	Select FinalQResult.DESCRIPTION,
	CASE FinalQResult.DESCRIPTION WHEN 'HARVESTING' THEN 
		'-Basic'
	ELSE CASE FinalQResult.DESCRIPTION WHEN 'ON COST' THEN
			'-On Cost'	
		 ELSE 	
			FinalQResult.DESCRIPTION
	     END
	END AS Description2,    
	CASE FinalQResult.DESCRIPTION WHEN 'ON COST' THEN
		0
	ELSE FinalQResult.AktualHK
	END AS AktualHK, 

	CASE ISNULL(D_SUM.CSAL_HK,0) WHEN 0
		THEN FinalQResult.RpHK
	ELSE
		CASE FinalQResult.DESCRIPTION WHEN 'HARVESTING' THEN
			--FinalQResult.AktualHK / NULLIF((D_SUM.CSAL_HK * D_SUM.JumlahUpah),0)
			FinalQResult.RpHK
		ELSE CASE FinalQResult.DESCRIPTION WHEN 'ON COST' THEN
			0 
		ELSE 
			FinalQResult.RpHK
			END
		END			 
	END AS RpHK,

	FinalQResult.YOP, 

	CASE ISNULL(D_SUM.CSAL_HK,0) WHEN 0
		THEN FinalQResult.Jumlah
	ELSE
		CASE FinalQResult.DESCRIPTION WHEN 'HARVESTING' THEN
			--FinalQResult.AktualHK / NULLIF((D_SUM.CSAL_HK * D_SUM.JumlahUpah),0)
			FinalQResult.Jumlah
		ELSE CASE FinalQResult.DESCRIPTION WHEN 'ON COST' THEN
			--FinalQResult.AktualHK / NULLIF((D_SUM.CSAL_HK * D_SUM.JumlahPembayaranLain),0)
			FinalQResult.Jumlah
		ELSE
			FinalQResult.Jumlah
		END
		END			 
	END AS Jumlah
	from
	(
		
	select 
	FinalResult.DESCRIPTION, FinalResult.AktualHK, FinalResult.RpHK, FinalResult.YOP, 
	FinalResult.Jumlah + TotBLooseFruits as [Jumlah],

	FinalResult.GangName,FinalResult.T0,
	FinalResult.T1,FinalResult.T2,FinalResult.T3,FinalResult.T4
	,A_COA.COACode, A_COA.OldCOACode, 
	G_T0.TValue as T0Value,G_T1.TValue as T1Value,G_T2.TValue as T2Value,G_T3.TValue as T3Value,G_T4.TValue as T4Value
	from    
	(     
	select 'PREMI PANEN' AS DESCRIPTION,0 as AktualHK, 0 as RpHK, SubResult.YOP, sum(isnull(SubResult.TotalPremi,0)) as Jumlah,SubResult.GangName  
	,SubResult.T0,SubResult.T1,SubResult.T2,SubResult.T3,SubResult.T4 from  
	(              
	SELECT C_RTD.EstateID                
	,G_ESTATE.EstateName                
	,C_RTD.ActiveMonthYearID                
	,G_AMY.AMonth                
	,G_AMY.AYear                
	,C_GM.GangName                
	,C_EMP.EmpCode                
	,C_EMP.EmpName                
	,C_RTD.RDate                
	,C_AS.AttendanceCode                
	,G_BM.BlockName                
	,G_BM.T0,G_BM.T1,G_BM.T2,G_BM.T3,G_BM.T4	
	,G_YOP.YOP                
	,G_DIV.DivName                
	,C_RTD.TotalBunches                
	,C_RTD.TBunches1                
	,C_RTD.TValue1                
	,C_RTD.TBunches2                
	,C_RTD.TValue2                
	,C_RTD.TBunches3                
	,C_RTD.TValue3                
	,'0' as TBunches4                
	,'0' as TValue4                
	,C_RTD.TotalBorongan                
	,C_RTD.TotalBoronganValue                
	,C_RTD.TotalLooseFruits                
	,C_RTD.TLooseFruitsValue                
	,TotalPremi =                
	ISNULL(C_RTD.TValue2, 0)                 
	+ ISNULL(C_RTD.TValue3, 0)                 
	+ ISNULL(C_RTD.TotalBoronganValue, 0)  
	+ ISNULL(C_RTD.TLooseFruitsValue, 0)          
	FROM                
	Checkroll.ReceptionTargetDetail AS C_RTD                
	INNER JOIN Checkroll.CREmployee AS C_EMP ON C_RTD.EmpID = C_EMP.EmpID                
	INNER JOIN General.Estate AS G_ESTATE ON C_RTD.EstateID = G_ESTATE.EstateID                
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_RTD.ActiveMonthYearID = G_AMY.ActiveMonthYearID                
	INNER JOIN Checkroll.DailyAttendance AS C_DA ON C_RTD.EmpID = C_DA.EmpID  AND C_RTD.RDate = C_DA.RDate                
	INNER JOIN Checkroll.AttendanceSetup AS C_AS ON C_DA.AttendanceSetupID = C_AS.AttendanceSetupID AND C_DA.EstateID = C_AS.EstateID                
	INNER JOIN Checkroll.GangMaster  AS C_GM ON C_RTD.GangMasterID = C_GM.GangMasterID                
	LEFT JOIN General.BlockMaster AS G_BM ON C_RTD.BlockID = G_BM.BlockID                
	LEFT JOIN General.YOP AS G_YOP ON C_RTD.YOPID = G_YOP.YOPID                
	LEFT JOIN General.Division AS G_DIV ON C_RTD.DivID = G_DIV.DivID       
	where C_RTD .EstateID = @EstateID                 
	AND C_RTD .ActiveMonthYearID = @ActiveMonthYearID              
	) as SubResult    
	group by SubResult.GangName,SubResult.YOP,SubResult.T0, SubResult.T1, SubResult.T2, SubResult.T3, SubResult.T4               
	) FinalResult    
	
	Left outer Join 
	(select C_GM.GangName,YOP.NAME,G_BM.T1,(SUM(isnull(BLooseFruits,0)) * isnull(LooseFruitsRate,0)) as TotBLooseFruits FROM Checkroll.DailyReceiption AS DR  
	INNER JOIN  Checkroll.ReceptionTargeDetail AS C_RTD on DR.DailyReceiptionDetID = C_RTD.DailyReceiptionDetID
	INNER JOIN Checkroll.DailyTeamActivity AS C_DTM ON C_RTD.GangMasterID = C_DTM.DailyTeamActivityID                 
	INNER JOIN Checkroll.GangMaster  AS C_GM ON C_DTM.GangMasterID = C_GM.GangMasterID 
	LEFT JOIN General.BlockMaster AS G_BM ON C_RTD.BlockID = G_BM.BlockID   
	inner join General.YOP as YOP on C_RTD.YOPID = YOP.YOPID 
	inner join (select top 1 EstateID, LooseFruitsRate FROM Checkroll.PremiSetup) PRSP on (PRSP.EstateID = @EstateID)
	where C_RTD .EstateID = @EstateID AND C_RTD .ActiveMonthYearID = @ActiveMonthYearID 
	group by C_GM.GangName,YOP.NAME,G_BM.T1,PRSP.LooseFruitsRate) as res4 on FinalResult.GangName = res4.GangName and FinalResult.YOP = res4.Name and FinalResult.T1 = res4.T1
	
	LEFT JOIN Checkroll.HarvestingDistribution HD on (upper(HD.DistributionType) = 'PREMI PANEN' and HD.T1 = FinalResult.T1) 
	LEFT JOIN Accounts.COA A_COA ON HD.COAID=A_COA.COAID  
	LEFT JOIN General.TAnalysis G_T0 ON HD.T0=G_T0.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T1 ON HD.T1=G_T1.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T2 ON HD.T2=G_T2.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T3 ON HD.T3=G_T3.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T4 ON HD.T4=G_T4.TAnalysisID

	union              

	select FinalResult.DESCRIPTION, FinalResult.AktualHK, 
	NULLIF(CAST(ISNULL(FinalResult.AktualHK,0) AS FLOAT),0) / NULLIF(CAST(ISNULL(res2.Hari,0) AS FLOAT),0) * (res2.Upah + res2.TotAllow + res2.TotTHR) AS RpHK
	,FinalResult.YOP ,
	NULLIF(CAST(ISNULL(FinalResult.AktualHK,0) AS FLOAT),0) / NULLIF(CAST(ISNULL(res2.Hari,0) AS FLOAT),0) * (res2.Upah + res2.TotAllow + res2.TotTHR),
	FinalResult.GangName, FinalResult.T0, FinalResult.T1, FinalResult.T2, FinalResult.T3, FinalResult.T4
	,A_COA.COACode, A_COA.OldCOACode, 
	G_T0.TValue as T0Value,G_T1.TValue as T1Value,G_T2.TValue as T2Value,G_T3.TValue as T3Value,G_T4.TValue as T4Value
	from    
	(     
	select 'HARVESTING' AS DESCRIPTION,sum(isnull(HK,0)) as AktualHK,               
	(select sum(isnull(HK,0)) * isnull(basicrate,0) from Checkroll.RateSetup  where Category = 'KHT') as RpHK,              
	SubResult.YOP as YOP, 
	(select sum(isnull(HK,0)) * isnull(basicrate,0) from Checkroll.RateSetup  where Category = 'KHT') as Jumlah, -- Lembur Not applicable, Lembur field is not included in Report
	SubResult.GangName, SubResult.T0,SubResult.T1,SubResult.T2,SubResult.T3,SubResult.T4 
	from               
	(              
	select DTA.GangName,GYOP.Name as YOP,DA.RDate,   
	G_Bl.T0,G_Bl.T1,G_Bl.T2,G_Bl.T3,G_Bl.T4,          
	--case when ASE.AttendanceCode in ('11','J1') then COUNT(*)*1 else COUNT(*)*0.5 end as HK,                   
	SUM(ISNULL(DR.BlkHK,0)) as HK,	
	(select FromDT  From General .FiscalYear where Period = @AMonth and FYear =@AYear) as FromDT ,                    
	(select ToDT   From General .FiscalYear where Period = @AMonth and FYear =@AYear) as ToDT                   
	from Checkroll.DailyAttendance DA                      
	--inner join (select distinct DailyReceiptionID,DivID,YOPID,BlockID from Checkroll.DailyReceiption) DR on (DA.DailyReceiptionID = DR.DailyReceiptionID)                    
	--inner JOIN General.yop AS GYOP on DR.YOPID = GYOP.YOPID                    
	--inner join Checkroll.AttendanceSetup ASE on (DA.AttendanceSetupID = ASE.AttendanceSetupID)                
	--inner join Checkroll.DailyTeamActivity DTA on (DA.DailyTeamActivityID = DTA.DailyTeamActivityID)                    
	inner join (select DailyReceiptionID,DivID,YOPID,BlockID, BlkHK from Checkroll.DailyReceiption) DR on (DA.DailyReceiptionID = DR.DailyReceiptionID)                    
	left JOIN General.yop AS GYOP on DR.YOPID = GYOP.YOPID                    
	left join Checkroll.AttendanceSetup ASE on (DA.AttendanceSetupID = ASE.AttendanceSetupID)                
	left join Checkroll.DailyTeamActivity DTA on (DA.DailyTeamActivityID = DTA.DailyTeamActivityID)                    
	left outer join General.BlockMaster G_Bl  on DR.BlockID=G_Bl.BlockID and DR.YOPID = G_Bl.YOPID and DR.DivID = G_Bl.DivID
	where ASE.AttendanceCode in ('11','J1','51') and (DA.ActiveMonthYearID = @ActiveMonthYearID) and upper(DTA.Activity) = 'PANEN'                    
	group by DTA.GangName,GYOP.Name,DA.RDate,ASE.AttendanceCode, G_Bl.T0,G_Bl.T1,G_Bl.T2,G_Bl.T3,G_Bl.T4                     
	) SubResult group by SubResult.GangName,SubResult.YOP,SubResult.T0, SubResult.T1, SubResult.T2, SubResult.T3, SubResult.T4

	) FinalResult    

	Left outer join 
	-- To Add the Allowance & THR values to 
	(select C_GM2.GangName,SUM(isnull(C_SALARY.Allowance,0)) as TotAllow, SUM(isnull(C_SALARY.Upah,0)) as Upah, 
	SUM(isnull(C_SALARY.THR,0)) as TotTHR, SUM(C_SALARY.Hari) as Hari
	from Checkroll.Salary as C_SALARY  
	inner join Checkroll.GangMaster as C_GM2 on C_GM2.GangMasterID = C_SALARY.GangMasterID   
	where C_SALARY.EstateID=C_GM2.EstateID and C_SALARY.ActiveMonthYearID = @ActiveMonthYearID  
	and C_GM2.EstateID=@EstateID group by C_GM2.GangName) as res2 on FinalResult.GangName = res2.GangName 

	Left outer Join 
	(select FinalResult.GangName, sum(FinalResult.TotHK) as GangTotHK
	from
	( -- Needs 2 Sub Query because Duplicate Records in GANGNAME
	select  SubResult.GangName, sum(isnull(HK,0)) as TotHK  
	from               
	(              
	select DTA.GangName, AttendanceCode  
	--,case when ASE.AttendanceCode in ('11','J1') then COUNT(*)*1 else COUNT(*)*0.5 end as HK 
	,SUM(ISNULL(DR.BlkHK,0)) as HK	
	from Checkroll.DailyAttendance DA                      
	--inner join (select distinct DailyReceiptionID,DivID,YOPID,BlockID from Checkroll.DailyReceiption) DR on (DA.DailyReceiptionID = DR.DailyReceiptionID)                    
	--INNER JOIN General.yop AS GYOP on DR.YOPID = GYOP.YOPID                    
	--inner join Checkroll.AttendanceSetup ASE on (DA.AttendanceSetupID = ASE.AttendanceSetupID)                
	--inner join Checkroll.DailyTeamActivity DTA on (DA.DailyTeamActivityID = DTA.DailyTeamActivityID)                    
	inner join (select DailyReceiptionID,DivID,YOPID,BlockID, BlkHK from Checkroll.DailyReceiption) DR on (DA.DailyReceiptionID = DR.DailyReceiptionID)                    
	left JOIN General.yop AS GYOP on DR.YOPID = GYOP.YOPID                    
	left join Checkroll.AttendanceSetup ASE on (DA.AttendanceSetupID = ASE.AttendanceSetupID)                
	left join Checkroll.DailyTeamActivity DTA on (DA.DailyTeamActivityID = DTA.DailyTeamActivityID)                    
	left outer join General.BlockMaster G_Bl  on DR.BlockID=G_Bl.BlockID and DR.YOPID = G_Bl.YOPID and DR.DivID = G_Bl.DivID
	where ASE.AttendanceCode in ('11','J1','51') and (DA.ActiveMonthYearID = @ActiveMonthYearID) and upper(DTA.Activity) = 'PANEN'     
	group by DTA.GangName,ASE.AttendanceCode               
	) SubResult  
	group by SubResult.GangName,SubResult.AttendanceCode 
	) as FinalResult 
	group by FinalResult.GangName) as res3 on FinalResult.GangName = res3.GangName 

	LEFT JOIN Checkroll.HarvestingDistribution HD on (upper(HD.DistributionType) = 'HARVESTING' and HD.T1 =FinalResult.T1)
	LEFT JOIN Accounts.COA A_COA ON HD.COAID=A_COA.COAID      
	LEFT JOIN General.TAnalysis G_T0 ON HD.T0=G_T0.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T1 ON HD.T1=G_T1.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T2 ON HD.T2=G_T2.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T3 ON HD.T3=G_T3.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T4 ON HD.T4=G_T4.TAnalysisID

	union 
  
	select FinalResult.*   
	,A_COA.COACode,A_COA.OldCOACode,
	G_T0.TValue as T0Value,G_T1.TValue as T1Value,G_T2.TValue as T2Value,G_T3.TValue as T3Value,G_T4.TValue as T4Value from    
	(  
	select 'ON COST' AS DESCRIPTION, 
	sum(isnull(HK,0)) as AktualHK, 
	0 as RpHK, SubResult.YOP,  
	--(ON_COST.total_Oncost * sum(isnull(HK,0))) / ON_COST.Total_Mandays as [Result],
	(NULLIF(CAST(SUM(ISNULL(HK,0)) as Float),0) / NULLIF(CAST(ISNULL(tblSal.Hari,0) as Float),0)) * ((TotalRoundUP-TotalNett) + JumlahPembayaranLain) as [Jumlah],
	SubResult.GangName 
	,SubResult.T1,SubResult.T0,SubResult.T2,SubResult.T3,SubResult.T4  
	from   
	(   
	select DTA.GangName, DTA.GangMasterID,
	G_Bl.T0,G_Bl.T1,G_Bl.T2,G_Bl.T3,G_Bl.T4,   -- G_BL =  BLOCK MASTER    
	GYOP.YOP,  
	--case when ASE.AttendanceCode in ('11','J1') then COUNT(*)*1 else COUNT(*)*0.5 end as HK       
	SUM(ISNULL(DR.BlkHK,0)) as HK
	from Checkroll.DailyAttendance DA            
	inner join Checkroll.DailyReceiption DR on DA.DailyReceiptionID = DR.DailyReceiptionID
	left JOIN General.yop AS GYOP on DR.YOPID = GYOP.YOPID          
	left join Checkroll.AttendanceSetup ASE on (DA.AttendanceSetupID = ASE.AttendanceSetupID)          
	left join Checkroll.DailyTeamActivity DTA on (DA.DailyTeamActivityID = DTA.DailyTeamActivityID)         
	left outer join General.BlockMaster G_Bl  on DR.BlockID=G_Bl.BlockID and DR.YOPID = G_Bl.YOPID and DR.DivID = G_Bl.DivID
	where ASE.AttendanceCode in ('11','J1','51') and DA.ActiveMonthYearID = @ActiveMonthYearID and upper(DTA.Activity) = 'PANEN'          
	group by DTA.GangName,DTA.GangMasterID,GYOP.YOP,ASE.AttendanceCode,G_Bl.T0,G_Bl.T1,G_Bl.T2,G_Bl.T3,G_Bl.T4 
	) SubResult 
	LEFT JOIN (
		SELECT 
		C_SALARY.GangMasterID,
		ROUND(SUM((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))),0) as TotalNett,
		SUM(CEILING((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))/1000.0) * 1000) as TotalRoundUP
		FROM Checkroll.Salary C_SALARY 
		INNER JOIN Checkroll.GangMaster C_GM ON C_SALARY.GangMasterID = C_GM.GangMasterID
		LEFT JOIN  (
		SELECT
		EmpID, GangMasterID,
		SUM(ISNULL(C_RTD.TLooseFruitsValue,0)) + SUM(ISNULL(C_RTD.TValue2,0)) + SUM(ISNULL(C_RTD.TValue3,0)) + SUM(ISNULL(C_RTD.TotalBoronganValue,0)) as Premi
		FROM Checkroll.ReceptionTargetDetail C_RTD
		WHERE C_RTD.ActiveMonthYearID = @ActiveMonthYearID
		GROUP BY EmpID, GangMasterID
		) tblPremi ON C_SALARY.EmpID = tblPremi.EmpID 
		WHERE C_SALARY.ActiveMonthYearID = @ActiveMonthYearID
		GROUP BY C_SALARY.GangMasterID, C_GM.CATEGORY
	 ) AS RoundUpTbl ON SubResult.GangMasterID = RoundUpTbl.GangMasterID
	 left join (
		select SUM(Hari) as Hari, GangMasterID from Checkroll.Salary sal WHERE ActiveMonthYearID = @ActiveMonthYearID group by GangMasterID
	) tblSal on SubResult.GangMasterID = tblSal.GangMasterID 
	LEFT JOIN ( 
			SELECT C_GM.GangMasterID AS DS_GangMasterID, 
			     C_GM.GangName AS DS_GangName,
			     SUM(ISNULL(C_S.Hari, 0)) as CSAL_HK,  
		    	 CASE SUM(ISNULL(C_S.Hari, 0)) WHEN 0 
					THEN 0
				 ELSE 
					ROUND((SUM(ISNULL(C_S.Upah, 0)+ISNULL(C_S.AttIncentiveRp, 0)+ISNULL(C_S.Allowance, 0)+ISNULL(C_THR.RoundUP, 0))+SUM(ISNULL(C_OPD.Totaldayvalue, 0)+(ISNULL(C_S.TotalRoundUP,0)-(ISNULL(C_S.TotalNett,0)-ISNULL(C_S.THR,0)+ISNULL(C_THR.RoundUP,0)))))
						/ SUM(ISNULL(C_S.Hari, 0)) ,2)  
				 END AS RataRataHK,
				 SUM(ISNULL(C_S.Upah, 0)+ISNULL(C_S.Allowance, 0)
				+ISNULL(C_THR.RoundUP, 0)) AS JumlahUpah,
				CASE C_GM.CATEGORY WHEN 'KHT'	
					THEN  
					SUM((ISNULL(C_OPD.Sickday, 0) * ISNULL(C_RS.BasicRate, 0))
					+((ISNULL(C_OPD.Holiday, 0)+ISNULL(C_OPD.Sunday, 0))
						* ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_OPD.Leaveday, 0) * ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_OPD.Rainday, 0) * ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_OPD.Adjday, 0) * ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_THR.RoundUP,0)-ISNULL(C_S.THR,0))
					+ISNULL(C_S.AttIncentiveRp, 0))  
				 ELSE SUM(ISNULL(C_S.AttIncentiveRp, 0))
				 END AS JumlahPembayaranLain

			FROM Checkroll.Salary AS C_S
				INNER JOIN Checkroll.GangMaster C_GM ON C_S.GangMasterID = C_GM.GangMasterID
				INNER JOIN Checkroll.OtherPaymentDetail C_OPD ON C_S.EmpID = C_OPD.EmpID AND C_S.ActiveMonthYearID = C_OPD.ActiveMonthYearID
				LEFT JOIN Checkroll.RateSetup AS C_RS ON C_RS.EstateID = C_S.EstateID AND C_RS.Category = C_GM.CATEGORY
				LEFT JOIN Checkroll.THR AS C_THR ON (C_THR.ActiveMonthYearID = C_S.ActiveMonthYearID AND C_THR.EmpID = C_S.EmpID AND C_THR.EstateID = C_S.EstateID)    
			WHERE C_S.EstateID = @EstateID
				AND C_S.ActiveMonthYearID = @ActiveMonthYearID
				AND UPPER(C_GM.Descp)='PANEN'
			GROUP BY C_GM.GangMasterID, C_GM.GangName, C_GM.Category, C_GM.Descp 
			) AS D_SUM ON D_SUM.DS_GangName = SubResult.GangName		
	/*
	full outer join (SELECT   
	C_GM4.GangName,
	(ISNULL(SUM(C_SAL.TotalRoundUP),0) - ISNULL(SUM(C_SAL.TotalNett),0))
	+ ISNULL(SUM(C_SAL.AttIncentiveRp),0) + ISNULL(SUM(C_SAL.HarinLainUpah),0) AS total_Oncost
	  ,ISNULL(SUM(C_SAL.Hari), 0) AS Total_Mandays 	
	FROM  
	Checkroll.Salary AS C_SAL  
	LEFT JOIN Checkroll.GangMaster AS C_GM4 ON C_SAL.GangMasterID = C_GM4.GangMasterID 
    
	where C_SAL .EstateID = 'M4'   
	AND C_SAL .ActiveMonthYearID = '04R971'
	AND UPPER(C_GM4.Descp) = 'PANEN'    
	AND C_GM4.GangName is not NULL  
    
	GROUP BY  
	C_GM4.GangName)    ON_COST ON ON_COST.GangName = SubResult.GangName
    */
	group by SubResult.GangName,SubResult.YOP,SubResult.T0,SubResult.T1,SubResult.T2,SubResult.T3,SubResult.T4
	,tblSal.Hari, RoundUpTbl.TotalRoundUP, RoundUpTbl.TotalNett, D_SUM.JumlahPembayaranLain      
	) FinalResult  
	LEFT JOIN Checkroll.HarvestingDistribution HD on (upper(HD.DistributionType) = 'ON COST' and HD.T1 =FinalResult.T1) 
	LEFT JOIN Accounts.COA A_COA ON HD.COAID=A_COA.COAID      
	LEFT JOIN General.TAnalysis G_T0 ON HD.T0=G_T0.TAnalysisID 
	LEFT JOIN General.TAnalysis G_T1 ON HD.T1=G_T1.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T2 ON HD.T2=G_T2.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T3 ON HD.T3=G_T3.TAnalysisID  
	LEFT JOIN General.TAnalysis G_T4 ON HD.T4=G_T4.TAnalysisID

	) As FinalQResult     
	LEFT JOIN ( 
			SELECT C_GM.GangMasterID AS DS_GangMasterID, 
			     C_GM.GangName AS DS_GangName,
			     SUM(ISNULL(C_S.Hari, 0)) as CSAL_HK,  
		    	 CASE SUM(ISNULL(C_S.Hari, 0)) WHEN 0 
					THEN 0
				 ELSE 
					ROUND((SUM(ISNULL(C_S.Upah, 0)+ISNULL(C_S.AttIncentiveRp, 0)+ISNULL(C_S.Allowance, 0)+ISNULL(C_THR.RoundUP, 0))+SUM(ISNULL(C_OPD.Totaldayvalue, 0)+(ISNULL(RoundUpTbl.TotalRoundUP,0)-(ISNULL(RoundUpTbl.TotalNett,0)-ISNULL(C_S.THR,0)+ISNULL(C_THR.RoundUP,0)))))
						/ SUM(ISNULL(C_S.Hari, 0)) ,2)  
				 END AS RataRataHK,
				 SUM(ISNULL(C_S.Upah, 0)+ISNULL(C_S.Allowance, 0)
				+ISNULL(C_THR.RoundUP, 0)) AS JumlahUpah,
				CASE C_GM.CATEGORY WHEN 'KHT'	
					THEN  
					SUM((ISNULL(C_OPD.Sickday, 0) * ISNULL(C_RS.BasicRate, 0))
					+((ISNULL(C_OPD.Holiday, 0)+ISNULL(C_OPD.Sunday, 0))
						* ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_OPD.Leaveday, 0) * ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_OPD.Rainday, 0) * ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_OPD.Adjday, 0) * ISNULL(C_RS.BasicRate, 0))
					+(ISNULL(C_THR.RoundUP,0)-ISNULL(C_S.THR,0))
					+ISNULL(C_S.AttIncentiveRp, 0))  
				 ELSE SUM(ISNULL(C_S.AttIncentiveRp, 0))
				 END AS JumlahPembayaranLain

			FROM Checkroll.Salary AS C_S
				INNER JOIN Checkroll.GangMaster C_GM ON C_S.GangMasterID = C_GM.GangMasterID
				INNER JOIN Checkroll.OtherPaymentDetail C_OPD ON C_S.EmpID = C_OPD.EmpID AND C_S.ActiveMonthYearID = C_OPD.ActiveMonthYearID
				LEFT JOIN Checkroll.RateSetup AS C_RS ON C_RS.EstateID = C_S.EstateID AND C_RS.Category = C_GM.CATEGORY
				LEFT JOIN Checkroll.THR AS C_THR ON (C_THR.ActiveMonthYearID = C_S.ActiveMonthYearID AND C_THR.EmpID = C_S.EmpID AND C_THR.EstateID = C_S.EstateID)    
				LEFT JOIN (
					SELECT 
					C_SALARY.GangMasterID,
					ROUND(SUM((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))),0) as TotalNett,
					SUM(CEILING((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))/1000.0) * 1000) as TotalRoundUP
					FROM Checkroll.Salary C_SALARY 
					INNER JOIN Checkroll.GangMaster C_GM ON C_SALARY.GangMasterID = C_GM.GangMasterID
					LEFT JOIN  (
					SELECT
					EmpID, GangMasterID,
					SUM(ISNULL(C_RTD.TLooseFruitsValue,0)) + SUM(ISNULL(C_RTD.TValue2,0)) + SUM(ISNULL(C_RTD.TValue3,0)) + SUM(ISNULL(C_RTD.TotalBoronganValue,0)) as Premi
					FROM Checkroll.ReceptionTargetDetail C_RTD
					WHERE C_RTD.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY EmpID, GangMasterID
					) tblPremi ON C_SALARY.EmpID = tblPremi.EmpID 
					WHERE C_SALARY.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY C_SALARY.GangMasterID, C_GM.CATEGORY
				 ) AS RoundUpTbl ON C_S.GangMasterID = RoundUpTbl.GangMasterID
			WHERE C_S.EstateID = @EstateID
				AND C_S.ActiveMonthYearID = @ActiveMonthYearID
				AND UPPER(C_GM.Descp)='PANEN'
			GROUP BY C_GM.GangMasterID, C_GM.GangName, C_GM.Category, C_GM.Descp 
			) AS D_SUM ON D_SUM.DS_GangName = FinalQResult.GangName		
	) As FinalTResult
	GROUP BY DESCRIPTION, Description2, YOP 
	--stanley@10-10-2011.e

	--select * from #DistCRPanen

--  NOTE : CONVERT(nvarchar(20), '-Separate') really not required here, when the SP is returning the records, to define the length in Crystal Report this function is used

	-- First delete all the records from [Checkroll].[AnalyHarvestingCost] table for the given @ActiveMonthYearID
	delete from [Checkroll].[AnalyHarvestingCost] where ActiveMonthYearID = @ActiveMonthYearID

	-- inserting the OthersWt (Mandays =0, below handled)
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	
	SELECT temp.EstateID, temp.ActiveMonthYearID, 'Loose Fruit (Kutip Brondolan)', CONVERT(nvarchar(20), '-Separate'),  temp.YOP ,
	1,0,0, temp.OthersWt,0,0,0,0,0,0,
	0,0,@CreatedBy,GetDate() 
	from
	(SELECT WBFruitWt.EstateID, WBFruitWt.ActiveMonthYearID,G_YOP.YOP, sum(WBFruitWtDet.OthersWt) as OthersWt
	FROM 
	Checkroll.WBFruitWtDetails AS WBFruitWtDet
	INNER JOIN Checkroll.WBFruitWt AS WBFruitWt ON WBFruitWtDet.WBFruitWtID = WBFruitWt.WBFruitWtID
	INNER JOIN General.Estate AS G_ESTATE ON WBFruitWt.EstateID = G_ESTATE.EstateID
	INNER JOIN General.YOP AS G_YOP ON WBFruitWtDet.YOPID = G_YOP.YOPID and WBFruitWt.EstateID = G_YOP.EstateID
	INNER JOIN General.ActiveMonthYear AS G_AMY ON WBFruitWt.ActiveMonthYearID = G_AMY.ActiveMonthYearID
	where WBFruitWt.EstateID = @EstateID and WBFruitWt.ActiveMonthYearID = @ActiveMonthYearID 
	group by WBFruitWt.EstateID, WBFruitWt.ActiveMonthYearID,G_YOP.YOP) temp 
	
	-- Following Variable are used in the cursor : CursLooseFruit
	declare @YOP nvarchar(50) 
	-- declare @Brondolan numeric(18,2) 
	declare @Mandays numeric(18,2) 
	declare @Total numeric(18,2) 

	-- Cursor to handle records to insert or update to table "checkroll.AnalyHarvestingCost" for the "Loose Fruit (Kutip Brondolan) - Seperate"
	-- NOTE : Brondolan is not used any where!
	Declare CursLooseFruit cursor for
	--02-12-2011 select Gyop.YOP, SUM(isnull(DAD.Mandays,0)), SUM(isnull(DAD.Mandays,0) * isnull(RSU.BasicRate,0)) -- SUM(isnull(DAD.Brondolan,0)),
	select 
		res1.YOP, SUM(res1.Mandays), SUM(res1.TCost)
	from
	(
	select Gyop.YOP, SUM(isnull(DAD.Mandays,0)) as Mandays, --SUM(isnull(DAD.Mandays,0) * isnull(RSU.BasicRate,0))   
	case when GM.Category = 'KHT' then
		((SUM(isnull(DAD.Mandays,0)+(isnull(DAD.OT, 0)/7))) * ISNULL(MAX( C_SRSETUP.Rate1KHT), 0)) 
			+ (   (ISNULL(MAX(C_SRSETUP.Rate2KHT), 0)       
				+ ISNULL(MAX(C_SRSETUP.Rate3KHT), 0)      
				+ ISNULL(MAX(C_SRSETUP.Rate4KHT), 0)      
				+ ISNULL(MAX(C_SRSETUP.Rate5KHT), 0)      
				+ ISNULL(MAX(C_SRSETUP.Rate6KHT), 0))       
				* (SUM(ISNULL(DAD.Mandays, 0)) + SUM(ISNULL(DAD.OT, 0)/7)))                                 
	else
		  SUM(isnull(DAD.Mandays,0) * Res2.KHLVal) --+  SUM(isnull(DAD.OT, 0)* res2.OTVal)
	end as TCost
	from Checkroll.DailyActivityDistribution DAD  
	inner join General.BlockMaster BM on (DAD.BlockID = BM.BlockID and DAD.DivID = BM.DivID)
	inner join General.YOP GYOP on (DAD.YOPID = GYOP.YOPID and DAD.DivID = GYOP.DivID) 
	inner join Checkroll.GangMaster GM on (DAD.GangMasterID = GM.GangMasterID)
	inner join Checkroll.RateSetup RSU on (GM.Category = RSU.Category)
	--02-12-2011.b
	LEFT JOIN Checkroll.StandardRateSetup AS C_SRSETUP ON DAD.EstateID = C_SRSETUP.EstateID      
    left join   
    (select C_GM2.GangMasterID,   
    ((SUM(isnull(C_SALARY.Upah,0)) + SUM(isnull(C_SALARY.HarinLainUpah,0)) +  SUM(isnull(C_SALARY.Allowance,0)) +  SUM(isnull(C_SALARY.THR,0)) + SUM(isnull(RoundUpTbl.TotalRoundUP,0))-SUM(isnull(RoundUpTbl.TotalNett,0))   ) / SUM(C_SALARY.HARI)) as KHTVal,  
    ((SUM(isnull(C_SALARY.Upah,0)) +  SUM(isnull(C_SALARY.Allowance,0)) +  SUM(isnull(C_SALARY.THR,0)) + SUM(isnull(RoundUpTbl.TotalRoundUP,0))-SUM(isnull(RoundUpTbl.TotalNett,0)) ) / SUM(C_SALARY.HARI)) as KHLVal,  
    (SUM(isnull(C_SALARY.TotalOTValue,0)) / SUM(C_SALARY.TotalOT)) as OTVal   
    from Checkroll.Salary as C_SALARY  
    inner join Checkroll.GangMaster as C_GM2 on C_GM2.GangMasterID = C_SALARY.GangMasterID 
	LEFT JOIN (
					SELECT 
					C_SALARY.GangMasterID,
					ROUND(SUM((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))),0) as TotalNett,
					SUM(CEILING((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))/1000.0) * 1000) as TotalRoundUP
					FROM Checkroll.Salary C_SALARY 
					INNER JOIN Checkroll.GangMaster C_GM ON C_SALARY.GangMasterID = C_GM.GangMasterID
					LEFT JOIN  (
					SELECT
					EmpID, GangMasterID,
					SUM(ISNULL(C_RTD.TLooseFruitsValue,0)) + SUM(ISNULL(C_RTD.TValue2,0)) + SUM(ISNULL(C_RTD.TValue3,0)) + SUM(ISNULL(C_RTD.TotalBoronganValue,0)) as Premi
					FROM Checkroll.ReceptionTargetDetail C_RTD
					WHERE C_RTD.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY EmpID, GangMasterID
					) tblPremi ON C_SALARY.EmpID = tblPremi.EmpID 
					WHERE C_SALARY.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY C_SALARY.GangMasterID, C_GM.CATEGORY
				 ) AS RoundUpTbl ON C_SALARY.GangMasterID = RoundUpTbl.GangMasterID
    where C_SALARY.EstateID=C_GM2.EstateID and C_SALARY.ActiveMonthYearID = @ActiveMonthYearID  
    and C_GM2.EstateID=@EstateID  
    group by C_GM2.GangMasterID) as res2 on DAD.GangMasterID = res2.GangMasterID
	--02-12-2011.e
	where DAD.Brondolan > 0 and isnull(DAD.BlockID,'') != '' and DAD.EstateID = @EstateID and DAD.ActiveMonthYearID = @ActiveMonthYearID
	--02-12-2011 group by Gyop.YOP 
	group by Gyop.YOP, GM.Category, Res2.KHTVal, Res2.KHLVal
	) as res1
	group by YOP 
		
		Open CursLooseFruit
		
		Fetch next from CursLooseFruit into @YOP,  @Mandays,@Total --@Brondolan,
			WHILE @@FETCH_STATUS = 0 
				BEGIN 
					
					if exists(select YOP from checkroll.AnalyHarvestingCost where 
							  EstateID = @EstateID and ActiveMonthYearID=@ActiveMonthYearID and 
							  MainDescription = 'Loose Fruit (Kutip Brondolan)' and SubDescription ='-Separate' and YOP = @YOP) 
						begin
							  update AHC set Mandays = @Mandays, Cost=@Total from Checkroll.AnalyHarvestingCost AHC where 
							  EstateID = @EstateID and ActiveMonthYearID=@ActiveMonthYearID and MainDescription='Loose Fruit (Kutip Brondolan)' 
							  and SubDescription ='-Separate' and YOP = @YOP 
						end
					else
						begin
							insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
							[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
							[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
							SELECT @EstateID, @ActiveMonthYearID, 'Loose Fruit (Kutip Brondolan)', CONVERT(nvarchar(20), '-Separate'), @YOP,
							1,0,0,0,0,@Mandays,0, @Total,0,0,
							0,0,@CreatedBy,GetDate() 
						end
					Fetch next from CursLooseFruit into @YOP, @Mandays,@Total --@Brondolan
				END
				
		close CursLooseFruit
	DEALLOCATE CursLooseFruit
	
	-- Incorporating the CostPerKG formula
	update AHC set CostPerKG = Cost / FactoryKG from Checkroll.AnalyHarvestingCost AHC where 
	EstateID=@EstateID and ActiveMonthYearID=@ActiveMonthYearID and MainDescription='Loose Fruit (Kutip Brondolan)' 
	and SubDescription ='-Separate' and isnull(FactoryKG,0) > 0


	-- HarvestersWt field taken from WBFruitWtDetails tables is not commented, the HarvestersWt is taken from Checkroll.ReceptionTargeDetail table

	-- inserting the HarvestersWt
	--insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP], 
	--[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches], 
	--[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 

	--SELECT tmp.EstateID, tmp.ActiveMonthYearID, 'Loose Fruit (Kutip Brondolan)', CONVERT(nvarchar(20), '-Harvester'), tmp.YOP, 
	--1,1,0,SUM(tmp.HarvestersWt),0,0,0,0,max(tmp.LooseFruitsRate),0, 
	--0,0,@CreatedBy,GetDate() 
	--from
	--(
	--SELECT temp.EstateID, temp.ActiveMonthYearID, temp.YOP, 
	--temp.HarvestersWt, temp.LooseFruitsRate 
	--from 
	--(SELECT WBFruitWt.EstateID, WBFruitWt.ActiveMonthYearID, WBFruitWtDet.YOPID,G_YOP.YOP, 
	--sum(WBFruitWtDet.HarvestersWt) as HarvestersWt,(select MAX(LooseFruitsRate) from 
	--Checkroll.PremiSetup where EstateID =@EstateID and YOPID = WBFruitWtDet.YOPID) as LooseFruitsRate 
	--FROM 
	--Checkroll.WBFruitWtDetails AS WBFruitWtDet
	--INNER JOIN Checkroll.WBFruitWt AS WBFruitWt ON WBFruitWtDet.WBFruitWtID = WBFruitWt.WBFruitWtID
	--INNER JOIN General.Estate AS G_ESTATE ON WBFruitWt.EstateID = G_ESTATE.EstateID
	--INNER JOIN General.YOP AS G_YOP ON WBFruitWtDet.YOPID = G_YOP.YOPID and WBFruitWt.EstateID = G_YOP.EstateID
	--INNER JOIN General.ActiveMonthYear AS G_AMY ON WBFruitWt.ActiveMonthYearID = G_AMY.ActiveMonthYearID
	--where WBFruitWt.EstateID = @EstateID and WBFruitWt.ActiveMonthYearID = @ActiveMonthYearID 
	--group by WBFruitWt.EstateID, WBFruitWt.ActiveMonthYearID,WBFruitWtDet.YOPID,G_YOP.YOP) temp) tmp 
	--group by tmp.EstateID, tmp.ActiveMonthYearID, tmp.YOP 

	--update AHC set AHC.Cost = AHC.CostPerKG * AHC.FactoryKG  from Checkroll.AnalyHarvestingCost AHC where 
	--EstateID=@EstateID and ActiveMonthYearID=@ActiveMonthYearID and MainDescription='Loose Fruit (Kutip Brondolan)' 
	--and SubDescription ='-Harvester'  
	
	---- inserting the HarvestersWt
	--insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP], 
	--[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches], 
	--[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 

	-- COmmented on 01-July-2011
	--SELECT @EstateID, @ActiveMonthYearID,'Loose Fruit (Kutip Brondolan)', CONVERT(nvarchar(20), '-Harvester'),G_YOP.NAME, 
	--1,1,0,SUM(ISNULL(C_RTD.TotalLooseFruits,0)) + SUM(ISNULL(C_DR.BLooseFruits, 0)),0,0,0,0,MAX(PSP.LooseFruitsRate),0, 
	--0,0,@CreatedBy,GetDate() from Checkroll.ReceptionTargeDetail C_RTD
	--inner join General.YOP As G_YOP on C_RTD.YOPID = G_YOP.YOPID
	--LEFT JOIN Checkroll.DailyReceiption AS C_DR ON C_RTD.DailyReceiptionDetID = C_DR.DailyReceiptionDetID
	--LEFT JOIN Checkroll.PremiSetup AS PSP ON C_RTD.EstateID = PSP.EstateID and C_RTD.YOPID = PSP.YOPID
	--where C_RTD.EstateID = @EstateID and C_RTD.ActiveMonthYearID = @ActiveMonthYearID group by G_YOP.NAME 
	
	--update AHC set AHC.Cost = AHC.CostPerKG * AHC.FactoryKG  from Checkroll.AnalyHarvestingCost AHC where 
	--EstateID=@EstateID and ActiveMonthYearID=@ActiveMonthYearID and MainDescription='Loose Fruit (Kutip Brondolan)' 
	--and SubDescription ='-Harvester'  
	
	-- inserting the HarvestersWt
	-- Following the same as Checkroll Report TOP 1 - Later may need to filter by YOPID also
	Declare @LooseFruitsRate decimal(18,2)
    select top 1 @LooseFruitsRate = isnull(LooseFruitsRate,0) from Checkroll.PremiSetup where EstateID = @EstateID

	-- Taken From Checkroll Report
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP], 
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches], 
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT 
		--@EstateID, @ActiveMonthYearID,'Loose Fruit (Kutip Brondolan)', CONVERT(nvarchar(20), '-Harvester'),G_YOP.NAME, 
		--1,1,0,SUM(ISNULL(C_RTD.TotalLooseFruits,0)) + SUM(ISNULL(C_DR.BLooseFruits, 0)) as TotalBrondolan,0,0,0,
		--( (SUM(ISNULL(C_RTD.TotalLooseFruits,0)) + SUM(ISNULL(C_DR.BLooseFruits, 0))) * @LooseFruitsRate ) as BrondolanRP, 
		--@LooseFruitsRate,0, 
		--0,0,@CreatedBy,GetDate()
		--stan@10-09-2011 
		@EstateID, @ActiveMonthYearID,'Loose Fruit (Kutip Brondolan)', CONVERT(nvarchar(20), '-Harvester'),G_YOP.NAME, 
		1,1,0,SUM(ISNULL(C_RTD.TotalLooseFruits,0)) as TotalBrondolan,0,0,0,
		--stanley@11-10-2011 ( (SUM(ISNULL(C_RTD.TotalLooseFruits,0)) + SUM(ISNULL(C_DR.BLooseFruits, 0))) * @LooseFruitsRate ) as BrondolanRP, 
		SUM(ISNULL(C_RTD.TLooseFruitsValue,0)) as BrondolanRP, 
		@LooseFruitsRate,0, 
		0,0,@CreatedBy,GetDate() 
	FROM             
		Checkroll.Salary AS C_SALARY    
		INNER JOIN Checkroll.CREmployee AS C_EMP ON C_SALARY.EmpID = C_EMP.EmpID    
		INNER JOIN General.Estate AS G_ESTATE ON C_SALARY.EstateID = G_ESTATE.EstateID     
		LEFT JOIN Checkroll.GangEmployeeSetup AS C_GES ON C_SALARY.EmpID = C_GES.EmpID    
		LEFT JOIN Checkroll.GangMaster AS C_GM ON C_GES.GangMasterID = C_GM.GangMasterID    
		INNER JOIN General.ActiveMonthYear AS G_AMY ON C_SALARY.ActiveMonthYearID = G_AMY.ActiveMonthYearID     
		LEFT JOIN Checkroll.ReceptionTargetDetail AS C_RTD ON C_SALARY.EmpID = C_RTD.EmpID    
		inner join General.YOP As G_YOP on C_RTD.YOPID = G_YOP.YOPID and C_RTD.EstateID = C_SALARY.EstateID and C_RTD.ActiveMonthYearID =C_SALARY.ActiveMonthYearID     
		--LEFT JOIN Checkroll.DailyReceiption AS C_DR ON C_RTD. = C_DR.DailyReceiptionDetID    

	Where     
		C_SALARY.EstateID = @EstateID AND     
		C_SALARY.ActiveMonthYearID = @ActiveMonthYearID AND    
		(C_SALARY.Category = 'KHL' or     
		-- below Only for KHT    
		(C_SALARY.Category = 'KHT'))     

	GROUP BY    
		G_YOP.Name     

	-- >>>>>>> till here
--	added by Stanley@03-08-2011.b
	Declare @JumlahUpah decimal(18,2)
	Declare @JumlahHari decimal(18,2)
	Declare @JumlahUpahLain decimal(18,2) 
	
	--SELECT  @JumlahUpah = SUM(ISNULL(C_S.Upah, 0)+ISNULL(C_S.Allowance, 0)) --+ISNULL(C_S.THR, 0))	
	--	,@JumlahHari = SUM(ISNULL(C_S.Hari, 0))
	--	,@JumlahUpahLain = SUM(ISNULL(C_S.TotalRoundUP,0) - ISNULL(C_S.TotalNett,0)-ISNULL(C_S.THR,0)+ISNULL(C_THR.RoundUP,0)
	--	+ ISNULL(C_S.AttIncentiveRp,0) + ISNULL(C_S.HarinLainUpah,0))
	--FROM Checkroll.Salary C_S 
	--INNER JOIN Checkroll.GangMaster C_GM ON C_GM.GangMasterID = C_S.GangMasterID
	--LEFT JOIN Checkroll.THR AS C_THR ON (C_THR.ActiveMonthYearID = C_S.ActiveMonthYearID 
	--		AND C_THR.EmpID = C_S.EmpID
	--		AND C_THR.EstateID = C_S.EstateID) 
	--WHERE Upper(C_GM.Descp) = 'PANEN'
	--	AND C_S.EstateID = @EstateID   
	--	AND C_S.ActiveMonthYearID =@ActiveMonthYearID  
	
	SELECT @JumlahHari = SUM(ISNULL(C_S.Hari, 0)),  
		@JumlahUpah = SUM(ISNULL(C_S.Upah, 0)+ISNULL(C_S.Allowance, 0)
			+ISNULL(C_THR.RoundUP, 0)),
		@JumlahUpahLain = SUM((ISNULL(C_OPD.Sickday, 0) * ISNULL(C_RS.BasicRate, 0))
				+((ISNULL(C_OPD.Holiday, 0)+ISNULL(C_OPD.Sunday, 0))
				* ISNULL(C_RS.BasicRate, 0))
				+(ISNULL(C_OPD.Leaveday, 0) * ISNULL(C_RS.BasicRate, 0))
				+(ISNULL(C_OPD.Rainday, 0) * ISNULL(C_RS.BasicRate, 0))
				+(ISNULL(C_OPD.Adjday, 0) * ISNULL(C_RS.BasicRate, 0))
				+(ISNULL(RoundUpTbl.TotalRoundUP,0)-(ISNULL(RoundUpTbl.TotalNett,0)-ISNULL(C_S.THR,0)+ISNULL(C_THR.RoundUP,0)))
				+ISNULL(C_S.AttIncentiveRp, 0)) 

	FROM Checkroll.Salary AS C_S
	INNER JOIN Checkroll.GangMaster C_GM ON C_S.GangMasterID = C_GM.GangMasterID
	INNER JOIN Checkroll.OtherPaymentDetail C_OPD ON C_S.EmpID = C_OPD.EmpID
			AND C_S.ActiveMonthYearID = C_OPD.ActiveMonthYearID
	LEFT JOIN Checkroll.RateSetup AS C_RS ON C_RS.EstateID = C_S.EstateID
			AND C_RS.Category = C_GM.CATEGORY
	LEFT JOIN Checkroll.THR AS C_THR ON (C_THR.ActiveMonthYearID = C_S.ActiveMonthYearID 
			AND C_THR.EmpID = C_S.EmpID 
			AND C_THR.EstateID = C_S.EstateID)    
	LEFT JOIN (
					SELECT 
					C_SALARY.GangMasterID,
					ROUND(SUM((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))),0) as TotalNett,
					SUM(CEILING((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))/1000.0) * 1000) as TotalRoundUP
					FROM Checkroll.Salary C_SALARY 
					INNER JOIN Checkroll.GangMaster C_GM ON C_SALARY.GangMasterID = C_GM.GangMasterID
					LEFT JOIN  (
					SELECT
					EmpID, GangMasterID,
					SUM(ISNULL(C_RTD.TLooseFruitsValue,0)) + SUM(ISNULL(C_RTD.TValue2,0)) + SUM(ISNULL(C_RTD.TValue3,0)) + SUM(ISNULL(C_RTD.TotalBoronganValue,0)) as Premi
					FROM Checkroll.ReceptionTargetDetail C_RTD
					WHERE C_RTD.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY EmpID, GangMasterID
					) tblPremi ON C_SALARY.EmpID = tblPremi.EmpID 
					WHERE C_SALARY.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY C_SALARY.GangMasterID, C_GM.CATEGORY
				 ) AS RoundUpTbl ON C_S.GangMasterID = RoundUpTbl.GangMasterID
	WHERE C_S.EstateID = @EstateID 
			AND C_S.ActiveMonthYearID = @ActiveMonthYearID
			AND UPPER(C_GM.Descp)='PANEN'

--	added by Stanley@03-08-2011.e


	print @JumlahUpah
	print @JumlahHari
	print @JumlahUpahLain

	--Declare @Amonth int
	--Declare @Ayear int
	--Select @Amonth =Amonth, @Ayear =ayear from General.ActiveMonthYear where EstateID = @EstateID and ActiveMonthYearID = @ActiveMonthYearID

	-- inserting the [Mandays] & [Cost]
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT @EstateID, @ActiveMonthYearID,'Harvester', CONVERT(nvarchar(20), '-Basic'),temp.YOP, 

--	commented by Stanley@03-08-2011	2,2,0,0,0,SUM(isnull(HK,0)),0,SUM(isnull(HK,0) * isnull(C_RS.BasicRate,0)),0,0,
	-- stanley@10-09-2011 2,2,0,0,0,SUM(isnull(HK,0)),0,ROUND(SUM((isnull(HK,0)/ @JumlahHari) * @JumlahUpah),0),0,0,
	--2,2,0,0,0,SUM(isnull(HK,0)),0,temp.Jumlah,0,0,
	2,2,0,0,0,isnull(DHK,0),0,temp.Jumlah,0,0,
	
	0,0,@CreatedBy,GetDate()
	from 
	(
	select DTA.GangMasterID,DTA.GangName,GYOP.YOP,DA.RDate,#DistCRPanen.Jumlah, 
	case when ASE.AttendanceCode in ('11','J1') then COUNT(*)*1 else COUNT(*)*0.5 end as HK, #DistCRPanen.HK as DHK,
	(select FromDT  From General .FiscalYear where Period = @Amonth and FYear =@Ayear) as FromDT ,    
	(select ToDT   From General .FiscalYear where Period = @Amonth and FYear =@Ayear) as ToDT   
	from Checkroll.DailyAttendance DA      
	inner join (select distinct DailyReceiptionID,YOPID from Checkroll.DailyReceiption) DR on (DA.DailyReceiptionID = DR.DailyReceiptionID)    
	INNER JOIN General.yop AS GYOP on DR.YOPID = GYOP.YOPID    
	inner join Checkroll.AttendanceSetup ASE on (DA.AttendanceSetupID = ASE.AttendanceSetupID)    
	inner join Checkroll.DailyTeamActivity DTA on (DA.DailyTeamActivityID = DTA.DailyTeamActivityID)   
    inner join  #DistCRPanen on (#DistCRPanen.Descript2 = '-Basic' and #DistCRPanen.YOP COLLATE DATABASE_DEFAULT = GYOP.YOP COLLATE DATABASE_DEFAULT)
	where ASE.AttendanceCode in ('11','J1','51') and DA.ActiveMonthYearID =@ActiveMonthYearID and DTA.Activity = 'panen'    
	group by DTA.GangMasterID,DTA.GangName,GYOP.YOP,DA.RDate,ASE.AttendanceCode, #DistCRPanen.Jumlah, #DistCRPanen.HK
	) temp
	INNER JOIN Checkroll.GangMaster AS C_GM ON temp.GangMasterID = C_GM.GangMasterID
	INNER JOIN Checkroll.RateSetup AS C_RS ON C_GM.Category = C_RS.Category
	group by temp.YOP, temp.Jumlah, DHK
	
	-- Taking the total HK from the above Query (Harvester / -Basic)
	declare @TotalHK decimal(18,2)
	select @TotalHK = SUM(isnull(Mandays,0)) from 
	checkroll.AnalyHarvestingCost where MainDescription ='Harvester' and SubDescription = '-Basic' and EstateID = @EstateID 
	and ActiveMonthYearID = @ActiveMonthYearID
	print 'total HK'
	print @TotalHK
    

	-- ON COST (Base : Checkroll.CRSalaryReport Report)
	-- Calculating the NET TOTAL HarinLainUpah + AttIncentiveRp (TotalRoundUP - TotalNett)
	declare @NetTotal decimal(18,2)

	select  
	--@NetTotal = sum( ISNULL(C_SALARY.HarinLainUpah,0) ) + sum(ISNULL(C_SALARY.AttIncentiveRp,0)) 
	--+ abs( sum(ISNULL(C_SALARY.TotalRoundUP,0)) - sum(ISNULL(C_SALARY.TotalNett,0)) )
	@NetTotal = sum(round(ISNULL(C_SALARY.HarinLainUpah,0),0 )) + sum( round( ISNULL(C_SALARY.AttIncentiveRp,0),0)) 
	 + round( abs( sum(ISNULL(RoundUpTbl.TotalRoundUP,0)) - sum(ISNULL(RoundUpTbl.TotalNett,0)) ),0)	

	FROM           
	Checkroll.Salary AS C_SALARY  
	INNER JOIN Checkroll.CREmployee AS C_EMP ON C_SALARY.EmpID = C_EMP.EmpID  
	INNER JOIN General.Estate AS G_ESTATE ON C_SALARY.EstateID = G_ESTATE.EstateID   
	LEFT JOIN Checkroll.GangEmployeeSetup AS C_GES ON C_SALARY.EmpID = C_GES.EmpID  
	LEFT JOIN Checkroll.GangMaster AS C_GM ON C_GES.GangMasterID = C_GM.GangMasterID  
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_SALARY.ActiveMonthYearID = G_AMY.ActiveMonthYearID   
	LEFT JOIN (
					SELECT 
					C_SALARY.GangMasterID,
					ROUND(SUM((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))),0) as TotalNett,
					SUM(CEILING((ISNULL(tblPremi.Premi, 0) + ISNULL(C_SALARY.TotalBasic,0) + ISNULL(C_SALARY.AttIncentiveRp,0) + ISNULL(C_SALARY.K3Panen,0) + ISNULL(C_SALARY.Allowance,0) + ISNULL(C_SALARY.THR,0) + ISNULL(C_SALARY.TotalOTValue,0) - ISNULL(C_SALARY.TotalDed,0))/1000.0) * 1000) as TotalRoundUP
					FROM Checkroll.Salary C_SALARY 
					INNER JOIN Checkroll.GangMaster C_GM ON C_SALARY.GangMasterID = C_GM.GangMasterID
					LEFT JOIN  (
					SELECT
					EmpID, GangMasterID,
					SUM(ISNULL(C_RTD.TLooseFruitsValue,0)) + SUM(ISNULL(C_RTD.TValue2,0)) + SUM(ISNULL(C_RTD.TValue3,0)) + SUM(ISNULL(C_RTD.TotalBoronganValue,0)) as Premi
					FROM Checkroll.ReceptionTargetDetail C_RTD
					WHERE C_RTD.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY EmpID, GangMasterID
					) tblPremi ON C_SALARY.EmpID = tblPremi.EmpID 
					WHERE C_SALARY.ActiveMonthYearID = @ActiveMonthYearID
					GROUP BY C_SALARY.GangMasterID, C_GM.CATEGORY
				 ) AS RoundUpTbl ON C_SALARY.GangMasterID = RoundUpTbl.GangMasterID
	Where   
	C_SALARY.EstateID = @EstateID AND   
	C_SALARY.ActiveMonthYearID =@ActiveMonthYearID AND 
	upper(C_GM.Descp) = 'PANEN'

	print '@NetTotal'
	print @NetTotal
	--print '@NetTHR'
	--print @NetTHR
	
	-- Calculating the Grand TOTAL PlantedHect
	declare @GrandTotalPlantedHect decimal(18,2)
	select @GrandTotalPlantedHect = round(sum(ISNULL(PlantedHect,0)),2) 
	from General.BlockMaster where EstateID = @EstateID and BlockStatus = 'Matured' 
	print '@GrandTotalPlantedHect'
	print @GrandTotalPlantedHect

--	added by Stanley@03-08-2011.b
	CREATE TABLE #YOPTotal (
				YOP nVArChar(50),
				HK decimal(18,2) )

	
    INSERT INTO #YOPTotal 
    select Tmp1.YOP, SUM(Tmp1.HK) from 
    (
	select YOP, case when ASE.AttendanceCode in ('11','J1') then COUNT(*)*1 else COUNT(*)*0.5 end As HK
	from Checkroll.DailyAttendance DA      
	inner join (select distinct DailyReceiptionID,YOPID from Checkroll.DailyReceiption) DR on (DA.DailyReceiptionID = DR.DailyReceiptionID)    
	INNER JOIN General.yop AS GYOP on DR.YOPID = GYOP.YOPID    
	inner join Checkroll.AttendanceSetup ASE on (DA.AttendanceSetupID = ASE.AttendanceSetupID)    
	inner join Checkroll.DailyTeamActivity DTA on (DA.DailyTeamActivityID = DTA.DailyTeamActivityID)   
	where ASE.AttendanceCode in ('11','J1','51') and DA.ActiveMonthYearID =@ActiveMonthYearID and DTA.Activity = 'panen'    
	group by YOP,ASE.AttendanceCode
    ) Tmp1
    group by Tmp1.YOP 
    
--    select * from #YOPTotal
--	added by Stanley@03-08-2011.e
	

	-- Harvester , -On Cost
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT @EstateID,@ActiveMonthYearID,'Harvester',CONVERT(nvarchar(20), '-On Cost'),temp.YOP,

--	commented by Stanley@03-08-2011	2,3,0,0,0,0,0,round (( @NetTotal / @GrandTotalPlantedHect ) * PlantedHect,0),0,0,
--	2,3,0,0,0,0,0,ROUND(SUM((isnull(temp.HK,0)* @JumlahUpahLain) / @JumlahHari),0),0,0,
	2,3,0,0,0,0,0, temp.Jumlah ,0,0,

	0,0,@CreatedBy,GetDate()
	from  
	(
--	commented by Stanley@03-08-2011		select YP.YOP, sum(PlantedHect) as PlantedHect
		select YP.YOP, #YOPTotal.HK, sum(PlantedHect) as PlantedHect, Jumlah
		from  General.BlockMaster BM
		inner join General.YOP YP on (BM.YOPID = YP.YOPID) 
		inner join 	#YOPTotal on (#YOPTotal.YOP COLLATE DATABASE_DEFAULT = YP.YOP COLLATE DATABASE_DEFAULT)	--	added by Stanley@03-08-2011
        inner join  #DistCRPanen on (#DistCRPanen.Descript2 = '-On Cost' and #DistCRPanen.YOP COLLATE DATABASE_DEFAULT = YP.YOP COLLATE DATABASE_DEFAULT)
		where BM.EstateID = @EstateID and BM.BlockStatus = 'Matured' 
--	commented by Stanley@03-08-2011		group by YP.YOP
		group by YP.YOP, #YOPTotal.HK, Jumlah
	) as temp
	group by temp.YOP, temp.Jumlah		--	added by Stanley@03-08-2011

	
	/*
	-- OLD Jamsostek Calculations
	-- inserting the [Cost]
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT C_DA.EstateID, C_DA.ActiveMonthYearID, 'Harvester',  CONVERT(nvarchar(20),'-Jamsostek'), G_YOP.YOP, 
	2,4,0,0,0,0,0, ( SUM(isnull(C_AS.TimesBasic,0)) * isnull(C_RS.BasicRate,0) * (isnull(C_RS.JHT,0) /100)),0,0,
	0,0,@CreatedBy,GetDate()
	FROM
	Checkroll.DailyReceiption AS C_DR
	INNER JOIN General.YOP AS G_YOP ON C_DR.YOPID = G_YOP.YOPID
	INNER JOIN Checkroll.DailyAttendance AS C_DA ON C_DR.DailyReceiptionID = C_DA.DailyReceiptionID
	INNER JOIN Checkroll.AttendanceSetup AS C_AS ON C_DA.AttendanceSetupID = C_AS.AttendanceSetupID
	AND C_AS.AttendanceCode NOT IN ('CB','CD', 'CH','CT', 'I0','I1', 'I2', 'S0', 'S1', 'S2', 'S3', 'S4')
	INNER JOIN Checkroll.DailyTeamActivity AS C_DTA ON C_DA.DailyTeamActivityID = C_DTA.DailyTeamActivityID
	INNER JOIN Checkroll.GangMaster AS C_GM ON C_DTA.GangMasterID = C_GM.GangMasterID
	INNER JOIN Checkroll.RateSetup AS C_RS ON C_GM.Category = C_RS.Category
	INNER JOIN General.Estate AS G_ESTATE ON C_DA.EstateID = G_ESTATE.EstateID
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_DA.ActiveMonthYearID = G_AMY.ActiveMonthYearID
	where C_DR.EstateID = @EstateID 
	AND C_DA.ActiveMonthYearID = @ActiveMonthYearID 
	GROUP BY
	C_DA.EstateID
	,G_ESTATE.EstateName
	,C_DA.ActiveMonthYearID
	,G_AMY.AMonth
	,G_AMY.AYear
	,C_GM.Category
	,C_RS.BasicRate
	,C_RS.JHT
	,C_RS.JK
	,C_RS.JKK
	,G_YOP.YOP 
	*/
	
	-- Jamsostek
	-- NOTE : @NoOfMan variable is used for both Jamsostek & THR
	Declare @NoOfMan decimal(18,2)
	/* commented by naxim on 14 sep 2013
	select @NoOfMan = COUNT(*) from Checkroll.GangEmployeeSetup as C_GES
	INNER JOIN Checkroll.CREmployee AS C_EMP ON C_GES.EmpID = C_EMP.EmpID 
	INNER JOIN Checkroll.GangMaster AS C_GMASTER ON C_GES.GangMasterID = C_GMASTER.GangMasterID
	where C_GES.EstateID =@EstateID and C_EMP.Status = 'Active' and upper(C_GMASTER.Descp) = 'PANEN' 
	*/
	select @NoOfMan = count(empid) from Checkroll.Salary a
	inner join Checkroll.GangMaster b on a.GangMasterID = b.GangMasterID
	where ActiveMonthYearID = @ActiveMonthYearID and a.EstateID = @EstateID and b.Descp = 'PANEN' 

	print '@NoOfMan'
	print @NoOfMan
	
	Declare @UMSP decimal(18,2)
	--select @UMSP = (@NoOfMan *  isnull(BasicRate,0) * ((isnull(RiceDividerDays,0) * (isnull(JHTEmployer,0) + isnull(JKK,0) + isnull(JK,0))/100) ))  from Checkroll.RateSetup WHERE Category = 'KHT' AND EstateID = @EstateID
	select @UMSP = (@NoOfMan *  isnull(BasicRate,0) * isnull(RiceDividerDays,0)) * (isnull(JHTEmployer,0) + isnull(JKK,0) + isnull(JK,0))/100  from Checkroll.RateSetup WHERE Category = 'KHT' AND EstateID = @EstateID
	print '@UMSP'
	print @UMSP
	print '@TotalHK'
	print @TotalHK
	
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	select @EstateID,@ActiveMonthYearID,'Harvester',CONVERT(nvarchar(20),'-Jamsostek'),YOP,
	2,4,0,0,0,0,0, (Mandays / @TotalHK) * @UMSP,0,0,
	0,0,@CreatedBy,GetDate() 
	from checkroll.AnalyHarvestingCost where MainDescription ='Harvester' and SubDescription = '-Basic' and EstateID = @EstateID and ActiveMonthYearID = @ActiveMonthYearID

	-- RICE PRICE
	-- NOTE : Active month Year ID is different for Module to Module (select * from General.ActiveMonthYear where ModID in (1,2) and AMonth = 4 and AYear = 2011)
	-- Declare @Amonth int
	-- Declare @Ayear int
	-- Select @Amonth =Amonth, @Ayear =ayear from General.ActiveMonthYear where EstateID = @EstateID and ActiveMonthYearID = @ActiveMonthYearID
	
	DECLARE @RicePrice numeric(18,2)
	SET @RicePrice = Isnull((Select RAPrice  from Checkroll.TaxAndRiceSetup),0)
	print '@RicePrice'
	print @RicePrice

	-- Calculating the Total RICE (KG)
	DECLARE @TotalRice numeric(18,2)
	set @TotalRice = (select SUM(temp.Bruto) as Bruto from 
		(select case when 
			(ISNULL(C_RAL.RiceMax,0)* 
			(ISNULL(C_ASUM.[11],0)+ISNULL(C_ASUM.J1, 0)+ISNULL(C_ASUM.[51], 0)+ISNULL(C_ASUM.CB, 0)+ISNULL(C_ASUM.CH, 0)+ISNULL(C_ASUM.CT, 0)+ISNULL(C_ASUM.I1, 0)+ISNULL(C_ASUM.I2, 0)+ISNULL(C_ASUM.S1, 0)+ISNULL(C_ASUM.S2, 0)+ ISNULL(C_ASUM.S3, 0) + ISNULL(C_ASUM.S4, 0)+ ISNULL(C_ASUM.CD, 0) + ISNULL(C_ASUM.H1,0) )) 
			/ 
			((SELECT DATEDIFF(DAY, G_FY.FromDT, G_FY.ToDT) +1 FROM General.FiscalYear AS G_FY WHERE G_FY.FYear = G_AMY.AYear AND G_FY.Period = G_AMY.AMonth)- 
			(Select DATEDIFF(WEEK, G_FY.FromDT, G_FY.ToDT) from General.FiscalYear AS G_FY WHERE G_FY.FYear = G_AMY.AYear AND G_FY.Period = G_AMY.AMonth) - 
--			(SELECT COUNT(*) FROM Checkroll.PublicHolidaySetup WHERE MONTH(PHDate) = G_AMY.AMonth AND YEAR(PHDATE) = G_AMY.AYear AND EstateID = C_ASUM.EstateID )) <= isnull(C_RAL.RiceMax,0) then
			(SELECT COUNT(*) FROM Checkroll.PublicHolidaySetup WHERE PHDate >= G_FY1.FromDT AND PHDate <= G_FY1.ToDT AND EstateID = C_ASUM.EstateID ) +
			(SELECT COUNT(*) FROM Checkroll.PublicHolidaySetup WHERE PHDate >= G_FY1.FromDT AND PHDate <= G_FY1.ToDT AND DAY(PHDate) = 6 AND EstateID = C_ASUM.EstateID)) <= isnull(C_RAL.RiceMax,0) then
			(ISNULL(C_RAL.RiceMax,0)*
			(ISNULL(C_ASUM.[11],0) 
			+ ISNULL(C_ASUM.J1, 0) 
			+ ISNULL(C_ASUM.[51], 0)  
			+ ISNULL(C_ASUM.CB, 0)    
			+ ISNULL(C_ASUM.CH, 0)    
			+ ISNULL(C_ASUM.CT, 0)    
			+ ISNULL(C_ASUM.I1, 0)    
			+ ISNULL(C_ASUM.I2, 0)
			+ ISNULL(C_ASUM.S1, 0)    
			+ ISNULL(C_ASUM.S2, 0)    
			+ ISNULL(C_ASUM.S3, 0)    
			+ ISNULL(C_ASUM.S4, 0)    
			+ ISNULL(C_ASUM.CD, 0)    
			+ ISNULL(C_ASUM.H1,0) ))  /    
			(
			(SELECT DATEDIFF(DAY , G_FY.FromDT, G_FY.ToDT) + 1 FROM General.FiscalYear AS G_FY WHERE G_FY.FYear = G_AMY.AYear AND G_FY.Period = G_AMY.AMonth)
			- 
			(Select DATEDIFF(WEEK, G_FY.FromDT, G_FY.ToDT) from General.FiscalYear AS G_FY WHERE G_FY.FYear = G_AMY.AYear AND G_FY.Period = G_AMY.AMonth)
			-
--			(SELECT COUNT(*) FROM Checkroll.PublicHolidaySetup WHERE MONTH(PHDate) = G_AMY.AMonth AND YEAR(PHDATE) = G_AMY.AYear AND EstateID = C_ASUM.EstateID))  
			(SELECT COUNT(*) FROM Checkroll.PublicHolidaySetup WHERE PHDate >= G_FY1.FromDT AND PHDate <= G_FY1.ToDT AND EstateID = C_ASUM.EstateID)
			+
			(SELECT COUNT(*) FROM Checkroll.PublicHolidaySetup WHERE PHDate >= G_FY1.FromDT AND PHDate <= G_FY1.ToDT AND DAY(PHDate) = 6 AND EstateID = C_ASUM.EstateID))  
		else  
			isnull(C_RAL.RiceMax,0)  
		end AS Bruto 
	from Checkroll.RiceAdvanceLog AS C_RAL
	INNER JOIN Checkroll.CREmployee AS C_EMP ON C_RAL.EmpID = C_EMP.EmpID    
	INNER JOIN Checkroll.GangEmployeeSetup AS C_GES ON C_RAL.EmpID = C_GES.EmpID
	INNER JOIN Checkroll.AttendanceSummary as C_ASUM ON C_ASUM .EmpID = C_RAL.EmpID     
	INNER JOIN Checkroll.GangMaster AS C_GMASTER ON C_GES.GangMasterID = C_GMASTER.GangMasterID
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_RAL.ActiveMonthYearID = G_AMY.ActiveMonthYearID    
	INNER JOIN General.FiscalYear AS G_FY1 ON (Year(G_FY1.ToDT) = G_AMY.AYear) AND (Month(G_FY1.ToDT) = G_AMY.AMonth)   
	where C_RAL.EstateID = @EstateID
	AND upper(C_GMASTER.Descp) = 'PANEN'
	AND C_RAL.ActiveMonthYearID = @ActiveMonthYearID
	AND C_ASUM.ActiveMonthYearID =C_RAL.ActiveMonthYearID) temp)  
	print '@TotalRice'
	print @TotalRice
		
	DECLARE @TotalRiceValue numeric(18,2)
	SET @TotalRiceValue = (@TotalRice * @RicePrice)
	print '@TotalRiceValue'
	print @TotalRiceValue
	
	---- Taking the total HK from the above Query (Harvester / -Basic)
	--declare @TotalHK decimal(18,2)
	--select @TotalHK = SUM(isnull(Mandays,0)) from 
	--checkroll.AnalyHarvestingCost where MainDescription ='Harvester' and SubDescription = '-Basic' and EstateID = @EstateID 
	--and ActiveMonthYearID = @ActiveMonthYearID
	--print 'total HK'
	--print @TotalHK

	-- inserting the [Cost]
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	select @EstateID,@ActiveMonthYearID,'Harvester',CONVERT(nvarchar(20),'-Rice'),YOP,
	2,5,0,0,0,0,0, Mandays / @TotalHK * @TotalRiceValue,0,0,
	0,0,@CreatedBy,GetDate() 
	from checkroll.AnalyHarvestingCost where MainDescription ='Harvester' and SubDescription = '-Basic' and EstateID = @EstateID and ActiveMonthYearID = @ActiveMonthYearID


	-- Harvester / thr
	Declare @RateSetupValue decimal(18,2)
	select @RateSetupValue = (isnull(BasicRate,0) * isnull(RiceDividerDays,0)) from Checkroll.RateSetup WHERE Category = 'KHT' AND EstateID = @EstateID
	print '@RateSetupValue'
	print @RateSetupValue
	
	--Declare @NoOfMan decimal(18,2)
	--select @NoOfMan = COUNT(*) from Checkroll.GangEmployeeSetup as C_GES
	--INNER JOIN Checkroll.CREmployee AS C_EMP ON C_GES.EmpID = C_EMP.EmpID 
	--INNER JOIN Checkroll.GangMaster AS C_GMASTER ON C_GES.GangMasterID = C_GMASTER.GangMasterID
	--where C_GES.EstateID =@EstateID and C_EMP.Status = 'Active' and upper(C_GMASTER.Descp) = 'PANEN' 
	print '@NoOfMan'
	print @NoOfMan
	
	Declare @TotalTHR decimal(18,2)
	set @TotalTHR  = (@RateSetupValue * @NoOfMan)
	print '@TotalTHR'
	print @TotalTHR
	
	Declare @NetTHR  decimal(18,2)
	set @NetTHR  = (@TotalTHR * 0.95)
	print '@NetTHR'
	print @NetTHR	
	
	--sai hide
	--insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	--[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	--[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	--SELECT @EstateID,@ActiveMonthYearID,'Harvester',CONVERT(nvarchar(20), '-THR'),temp.YOP,
	--2,6,0,0,0,0,0, ((@NetTHR / @GrandTotalPlantedHect ) * PlantedHect)/12,0,0,
	--0,0,@CreatedBy,GetDate()
	--from  
	--(
	--	select YP.YOP, sum(PlantedHect) as PlantedHect
	--	from  General.BlockMaster BM
	--	inner join General.YOP YP on (BM.YOPID = YP.YOPID) 
	--	where BM.EstateID = @EstateID and BM.BlockStatus = 'Matured' 
	--	group by YP.YOP
	--) as temp

	
	/* Please do not remove the following Query, Future we may require this  
	-- inserting the [Cost]
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT C_RTD.EstateID,C_RTD.ActiveMonthYearID,'Harvester',CONVERT(nvarchar(20),'-Loose Fruits'),G_YOP.YOP,
	2,7,0,0,0,0,0,SUM(isnull(C_RTD.TotalLooseFruits,0)),0,0,
	0,0,@CreatedBy,GetDate()
	FROM
	Checkroll.ReceptionTargeDetail AS C_RTD
	INNER JOIN General.YOP AS G_YOP ON C_RTD.YOPID = G_YOP.YOPID
	INNER JOIN General.Estate AS G_ESTATE ON C_RTD.EstateID = G_ESTATE.EstateID
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_RTD.ActiveMonthYearID = G_AMY.ActiveMonthYearID
	where C_RTD.EstateID = @EstateID AND C_RTD.ActiveMonthYearID = @ActiveMonthYearID 
	GROUP BY
	C_RTD.EstateID
	,G_ESTATE.EstateName
	,C_RTD.ActiveMonthYearID
	,G_AMY.AMonth
	,G_AMY.AYear
	,G_YOP.YOP
	*/
	
	
	-- Calculating NActualBunches + BActualBunches per YOP & inserting record into checkroll.AnalyHarvestingCost
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	
	-- commented by stanley@08-09-2011.b		
	--SELECT temp.EstateID,temp.ActiveMonthYearID, 'Harvester Fruits' , CONVERT(nvarchar(20), 'Bunches / FFB') ,temp.YOP,
	--3,8, 0, FactoryKG, 0, 0, 0 , 0, 0, 0, 
	--temp.FFBBunches ,0, @CreatedBy,GetDate() 
	--from (
	--SELECT WBFruitWt.EstateID,WBFruitWt.ActiveMonthYearID, G_YOP.YOP,
	--sum(WBFruitWtDet.FFBWt) AS FactoryKG, sum(WBFruitWtDet.FFBBunches) as  FFBBunches
	--FROM
	--	Checkroll.WBFruitWtDetails AS WBFruitWtDet
	--	INNER JOIN Checkroll.WBFruitWt AS WBFruitWt ON WBFruitWtDet.WBFruitWtID = WBFruitWt.WBFruitWtID
	--	INNER JOIN General.Estate AS G_ESTATE ON WBFruitWt.EstateID = G_ESTATE.EstateID
	--	INNER JOIN General.YOP AS G_YOP ON WBFruitWtDet.YOPID = G_YOP.YOPID and WBFruitWt.EstateID = G_YOP.EstateID
	--	INNER JOIN General.ActiveMonthYear AS G_AMY ON WBFruitWt.ActiveMonthYearID = G_AMY.ActiveMonthYearID
	--	where WBFruitWt.EstateID = @EstateID and WBFruitWt.ActiveMonthYearID = @ActiveMonthYearID
	--	group by WBFruitWt.EstateID, WBFruitWt.ActiveMonthYearID,G_YOP.YOP) temp 
	-- commented by stanley@08-09-2011.e		

    -- added by stanley@08-09-2011.b
	SELECT temp.EstateID,temp.ActiveMonthYearID, 'Harvester Fruits' , CONVERT(nvarchar(20), 'Bunches / FFB') ,temp.YOP,
	3, 8, temp.TotalBunches, 0, 0, 0, 0, 0, 0, 0, 0 ,0, 'SuperAdmin',GetDate() 
	from 
	(
	SELECT C_DA.EstateID, C_DA.ActiveMonthYearID,  
	G_YOP.YOP, sum(isnull(C_DRT.HarvestedNormal,0) + isnull(C_DRT.HarvestedBorongan,0)) TotalBunches   
	FROM  Checkroll.DailyAttendance AS C_DA  
	INNER JOIN Checkroll.DailyReceiption AS C_DR ON C_DA.DailyReceiptionID = C_DR.DailyReceiptionID  
	INNER JOIN Checkroll.DailyReceptionWithTeam AS C_DRT ON C_DR.DailyReceiptionDetID = C_DRT.DailyReceiptionDetID
	INNER JOIN Checkroll.DailyTeamActivity AS C_DTA ON C_DA.DailyTeamActivityID = C_DTA.DailyTeamActivityID  
	AND C_DA.RDate = C_DTA.DDate  
	INNER JOIN Checkroll.GangMaster AS C_GM ON C_DTA.GangMasterID = C_GM.GangMasterID  
	INNER JOIN Checkroll.CREmployee AS C_EMP ON C_DA.EmpID = C_EMP.EmpID  
	INNER JOIN Checkroll.AttendanceSetup AS C_AS ON C_DA.AttendanceSetupID = C_AS.AttendanceSetupID  
	AND C_DA.EstateID = C_AS.EstateID  
	LEFT JOIN General.BlockMaster AS G_BM ON C_DR.BlockID = G_BM.BlockID  
	LEFT JOIN General.YOP AS G_YOP ON C_DR.YOPID = G_YOP.YOPID  
	LEFT JOIN General.Division AS G_DIV ON C_DR.DivID = G_DIV.DivID  
	INNER JOIN General.Estate AS G_ESTATE ON C_DA.EstateID = G_ESTATE.EstateID  
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_DA.ActiveMonthYearID = G_AMY.ActiveMonthYearID  
	WHERE  
	C_DA.ActiveMonthYearID = @ActiveMonthYearID
	AND C_DA.EstateID = @EstateID
	group by C_DA.EstateID, C_DA.ActiveMonthYearID, G_YOP.YOP
	) temp 		
    -- added by stanley@08-09-2011.e
		
	--update AHC set Mandays = @Mandays, Cost=@Total from Checkroll.AnalyHarvestingCost AHC where 
	--EstateID=@EstateID and ActiveMonthYearID=@ActiveMonthYearID and MainDescription='Loose Fruit (Kutip Brondolan)' 
	--and SubDescription ='-Separate' and YOP = @YOP 
	
	-- commented by stanley@08-09-2011.b		
	---- Calculating NActualBunches + BActualBunches & updating in the above query
	--update AHC set AHC.PayrollBunches = Temp.TotalBunches from Checkroll.AnalyHarvestingCost AHC,
	--(SELECT   
	--G_YOP.YOP, sum(isnull(C_DR.NActualBunches,0) + isnull(C_DR.BActualBunches,0)) TotalBunches   
	--FROM  
	--Checkroll.DailyAttendance AS C_DA  
	--INNER JOIN Checkroll.DailyReceiption AS C_DR ON C_DA.DailyReceiptionID = C_DR.DailyReceiptionID  
	--INNER JOIN Checkroll.DailyTeamActivity AS C_DTA ON C_DA.DailyTeamActivityID = C_DTA.DailyTeamActivityID  
	--AND C_DA.RDate = C_DTA.DDate  
	--INNER JOIN Checkroll.GangMaster AS C_GM ON C_DTA.GangMasterID = C_GM.GangMasterID  
	--INNER JOIN Checkroll.CREmployee AS C_EMP ON C_DA.EmpID = C_EMP.EmpID  
	--INNER JOIN Checkroll.AttendanceSetup AS C_AS ON C_DA.AttendanceSetupID = C_AS.AttendanceSetupID  
	--AND C_DA.EstateID = C_AS.EstateID  
	--LEFT JOIN General.BlockMaster AS G_BM ON C_DR.BlockID = G_BM.BlockID  
	--LEFT JOIN General.YOP AS G_YOP ON C_DR.YOPID = G_YOP.YOPID  
	--LEFT JOIN General.Division AS G_DIV ON C_DR.DivID = G_DIV.DivID  
	--INNER JOIN General.Estate AS G_ESTATE ON C_DA.EstateID = G_ESTATE.EstateID  
	--INNER JOIN General.ActiveMonthYear AS G_AMY ON C_DA.ActiveMonthYearID = G_AMY.ActiveMonthYearID  
	--WHERE  
	--C_DA.ActiveMonthYearID = @ActiveMonthYearID
	--AND C_DA.EstateID = @EstateID
	--group by G_YOP.YOP
	--) temp 
	--where AHC.EstateID=@EstateID and AHC.ActiveMonthYearID=@ActiveMonthYearID and AHC.MainDescription='Harvester Fruits' 
	--and AHC.SubDescription ='Bunches / FFB' and AHC.YOP = temp.YOP
	-- commented by stanley@08-09-2011.e		
	
    -- added by stanley@08-09-2011.b 
	---- Calculating FactoryKg and FactoryBunches & updating in the above query
	update AHC set AHC.FactoryKG = temp.FactoryKG, AHC.FactoryBunches = temp.FFBBunches from Checkroll.AnalyHarvestingCost AHC,
	(
	--sai
	SELECT sum(CS.MilWeight) AS FactoryKG, sum(CS.Bunches) as  FFBBunches,
			G_YOP.YOP 
	FROM
		Checkroll.CropStatement AS CS
		INNER JOIN General.Estate AS G_ESTATE ON CS.EstateID = G_ESTATE.EstateID
		INNER JOIN General.YOP AS G_YOP ON CS.YOPID = G_YOP.YOPID and CS.EstateID = G_YOP.EstateID
		--INNER JOIN General.ActiveMonthYear AS G_AMY ON WBFruitWt.ActiveMonthYearID = G_AMY.ActiveMonthYearID
		where CS.EstateID = @EstateID and Month(CS.DDate) = @Amonth and Year(CS.DDate) = @Ayear 
		group by CS.EstateID,G_YOP.YOP
	) temp 
	where AHC.EstateID=@EstateID and AHC.ActiveMonthYearID=@ActiveMonthYearID and AHC.MainDescription='Harvester Fruits' 
	and AHC.SubDescription ='Bunches / FFB' and AHC.YOP = temp.YOP
    -- added by stanley@08-09-2011.e


	-- Checkroll Report
	--===========================
	-- Incentive
	--===========================
    insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT C_RTD.EstateID, C_RTD.ActiveMonthYearID, 'Incentive',CONVERT(nvarchar(20),'-Target 1'),G_YOP.YOP,
	4,9,0,0,0,0,0,SUM(isnull(C_RTD.TValue2,0)),0,0,
	0,0, @CreatedBy,GetDate() 
	FROM
	Checkroll.ReceptionTargetDetail AS C_RTD
	INNER JOIN General.YOP AS G_YOP ON C_RTD.YOPID = G_YOP.YOPID
	INNER JOIN General.Estate AS G_ESTATE ON C_RTD.EstateID = G_ESTATE.EstateID
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_RTD.ActiveMonthYearID = G_AMY.ActiveMonthYearID
	where C_RTD.EstateID = @EstateID 
		AND C_RTD.ActiveMonthYearID = @ActiveMonthYearID 
	GROUP BY
		C_RTD.EstateID
		,G_ESTATE.EstateName
		,C_RTD.ActiveMonthYearID
		,G_AMY.AMonth
		,G_AMY.AYear
		,G_YOP.YOP
	
	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT C_RTD.EstateID, C_RTD.ActiveMonthYearID, 'Incentive', CONVERT(nvarchar(20),'-Target 2'), G_YOP.YOP,
	4,10,0, 0, 0, 0,0,SUM(isnull(C_RTD.TValue3,0)),0,0,
	0,0, @CreatedBy,GetDate() 
	FROM
		Checkroll.ReceptionTargetDetail AS C_RTD
		INNER JOIN General.YOP AS G_YOP ON C_RTD.YOPID = G_YOP.YOPID
		INNER JOIN General.Estate AS G_ESTATE ON C_RTD.EstateID = G_ESTATE.EstateID
		INNER JOIN General.ActiveMonthYear AS G_AMY ON C_RTD.ActiveMonthYearID = G_AMY.ActiveMonthYearID
		where C_RTD.EstateID = @EstateID 
		AND C_RTD.ActiveMonthYearID = @ActiveMonthYearID 
	GROUP BY
		C_RTD.EstateID
		,G_ESTATE.EstateName
		,C_RTD.ActiveMonthYearID
		,G_AMY.AMonth
		,G_AMY.AYear
		,G_YOP.YOP


	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT C_RTD.EstateID,C_RTD.ActiveMonthYearID,'Incentive',CONVERT(nvarchar(20),'-Target 3'),G_YOP.YOP,
    4,11,0, 0, 0, 0, 0,0, 0, 0,
    0, 0 ,@CreatedBy,GetDate() 
    FROM
		Checkroll.ReceptionTargetDetail AS C_RTD
		INNER JOIN General.YOP AS G_YOP ON C_RTD.YOPID = G_YOP.YOPID
		INNER JOIN General.Estate AS G_ESTATE ON C_RTD.EstateID = G_ESTATE.EstateID
		INNER JOIN General.ActiveMonthYear AS G_AMY ON C_RTD.ActiveMonthYearID = G_AMY.ActiveMonthYearID
		where C_RTD.EstateID = @EstateID 
		AND C_RTD.ActiveMonthYearID = @ActiveMonthYearID 
		
	GROUP BY
		C_RTD.EstateID
		,G_ESTATE.EstateName
		,C_RTD.ActiveMonthYearID
		,G_AMY.AMonth
		,G_AMY.AYear
		,G_YOP.YOP

	insert into checkroll.AnalyHarvestingCost([EstateID],[ActiveMonthYearID],[MainDescription],[SubDescription],[YOP],
	[MainOrderCounter],[SubOrderCounterMain],[PayrollBunches],[FactoryKG],[KGPerBunches],[Mandays],[KGPerMandays],[Cost],[CostPerKG],[CostPerBunches],
	[FactoryBunches],[DifferenceBunches],[CreatedBy],[CreatedOn]) 
	SELECT C_RTD.EstateID,C_RTD.ActiveMonthYearID,'Incentive',CONVERT(nvarchar(20),'-Borongan'), G_YOP.YOP, 
	4,12,0, 0, 0, 0, 0,SUM(isnull(C_RTD.TotalBoronganValue,0)), 0, 0, 
	0, 0,@CreatedBy,GetDate() 
	FROM
		Checkroll.ReceptionTargetDetail AS C_RTD
		INNER JOIN General.YOP AS G_YOP ON C_RTD.YOPID = G_YOP.YOPID
		INNER JOIN General.Estate AS G_ESTATE ON C_RTD.EstateID = G_ESTATE.EstateID
		INNER JOIN General.ActiveMonthYear AS G_AMY ON C_RTD.ActiveMonthYearID = G_AMY.ActiveMonthYearID
		where C_RTD.EstateID = @EstateID 
		AND C_RTD.ActiveMonthYearID = @ActiveMonthYearID 

	GROUP BY
		C_RTD.EstateID
		,G_ESTATE.EstateName
		,C_RTD.ActiveMonthYearID
		,G_AMY.AMonth
		,G_AMY.AYear
		,G_YOP.YOP
	ORDER BY G_YOP.YOP
	

 -- select * from  Checkroll.AnalyHarvestingCost where ActiveMonthYearID = @ActiveMonthYearID

--Added by stanley@04-08-2011.b
	Declare @LooseFruits_SubTotal decimal(18,2)
	Declare @FactoryKG_YOP_Total decimal(18,2)
	Declare @MainDescription nVarChar(50)
	Declare @SubDescription	 nVarChar(50)
	Declare @TotalCost_Harvester decimal(18,2)

	Declare CursAnalyHarvCost cursor for 
	select YOP, MainDescription, SubDescription from Checkroll.AnalyHarvestingCost
	where EstateID = @EstateID and ActiveMonthYearID =@ActiveMonthYearID
	and MainDescription = 'Harvester Fruits' 
	and SubDescription = 'Bunches / FFB'
	
		Open CursAnalyHarvCost
		Fetch next from CursAnalyHarvCost into @YOP,  @MainDescription, @SubDescription
			While @@FETCH_STATUS = 0 
				BEGIN 
				
					SET @TotalCost_Harvester = (
						SELECT SUM(COST) FROM Checkroll.AnalyHarvestingCost
						WHERE EstateID = @EstateID AND ActiveMonthYearID =@ActiveMonthYearID AND YOP = @YOP
						AND MainDescription = 'Harvester' 
						AND SubDescription in ( '-Basic', '-On Cost', '-Jamsostek', '-Rice', '-THR')
						GROUP BY YOP, MainDescription
					)
					
					SET @LooseFruits_SubTotal = ( 
						SELECT SUM(FactoryKG) FROM Checkroll.AnalyHarvestingCost
						WHERE EstateID = @EstateID AND ActiveMonthYearID =@ActiveMonthYearID AND YOP = @YOP
						AND MainDescription = 'Loose Fruit (Kutip Brondolan)' 
						AND SubDescription in ('-Harvester', '-Separate')
						GROUP BY YOP, MainDescription
					)

					SET @FactoryKG_YOP_Total = ( 
						SELECT SUM(FactoryKG) FROM Checkroll.AnalyHarvestingCost
						where EstateID = @EstateID AND ActiveMonthYearID =@ActiveMonthYearID AND YOP = @YOP
						GROUP BY YOP 
					)
					
					UPDATE Checkroll.AnalyHarvestingCost SET FactoryKG = Case FactoryKG When 0 then 0 else (FactoryKG - @LooseFruits_SubTotal) end,
					-- commented by stanley@08-09-2011		CostPerKG = (@TotalCost_Harvester / FactoryKG),	
					 		CostPerKG = Case FactoryKG When 0 then 0 else (@TotalCost_Harvester / NULLIF((FactoryKG),0)) end,	
							CostPerBunches = (@TotalCost_Harvester / NULLIF(PayrollBunches,0))
						WHERE EstateID = @EstateID AND ActiveMonthYearID =@ActiveMonthYearID AND YOP = @YOP
							AND MainDescription = 'Harvester Fruits' 
							AND SubDescription = 'Bunches / FFB' 
									
					UPDATE Checkroll.AnalyHarvestingCost SET CostPerKG = Case FactoryKG When 0 then 0 else (@TotalCost_Harvester / NULLIF(FactoryKG,0)) end,	
							CostPerBunches = (@TotalCost_Harvester / NULLIF(PayrollBunches,0)),
							KGPerBunches = (FactoryKG / NULLIF(PayrollBunches,0))
						WHERE EstateID = @EstateID AND ActiveMonthYearID =@ActiveMonthYearID AND YOP = @YOP
							AND MainDescription = 'Harvester Fruits' 
							AND SubDescription = 'Bunches / FFB' 

					Fetch next from CursAnalyHarvCost into @YOP,  @MainDescription, @SubDescription
				END
		close CursAnalyHarvCost
	DEALLOCATE CursAnalyHarvCost
	
	UPDATE Checkroll.AnalyHarvestingCost SET MainDescription = 'Harvester', MainOrderCounter = 2,
	SubOrderCounterMain = 7 	
	WHERE EstateID = @EstateID AND ActiveMonthYearID =@ActiveMonthYearID
	AND MainDescription = 'Harvester Fruits' 
--Added by stanley@04-08-2011.e
	--stanley@10-09-2011
	drop table #DistCRPanen
	drop table #YOPTotal

END
