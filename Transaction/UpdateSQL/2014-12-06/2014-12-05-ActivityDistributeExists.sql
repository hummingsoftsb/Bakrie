USE [BSPMS_SR]
GO
/****** Object:  StoredProcedure [Checkroll].[ActivityDistributeExists]    Script Date: 12/5/2014 4:06:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================  
-- Created By : SIVA  
-- Modified By:  
-- Created date: 02 DEC 2010
-- Last Modified Date:
-- Used by : Monthly Proccessing
-- ===================================================== 
ALTER PROCEDURE [Checkroll].[ActivityDistributeExists]
-- Add the parameters for the stored procedure here
                                                    (@ActiveMonthYearId nvarchar(50),
                                                    @EstateID nvarchar(50) ,
                                                    @User nvarchar (50)
                                                    )
AS

SELECT distinct 
GangName ,DistbDate ,TotalHK ,DistributedHK , TotalOT, DistributedOT 
 FROM

(
SELECT A.GangName ,A.GangMasterID ,A .DistbDate ,B.TotalHK As TotalHK,A .ADMandays As DistributedHK ,B.TotalOT As TotalOT,A .ADOT As DistributedOT   FROM 

(SELECT  CR_DAD.GangMasterID  ,C_GM .GangName ,CR_DAD.DistbDate, ISNULL(SUM(CR_DAD.Mandays),0) as ADMandays ,ISNULL(SUM(CR_DAD.OT),0)  as ADOT   FROM
		Checkroll.DailyActivityDistribution AS CR_DAD 
		INNER JOIN Checkroll .GangMaster C_GM ON C_GM .GangMasterID =CR_DAD .GangMasterID 
		WHERE CR_DAD.GangMasterID IS NOT NULL AND CR_DAD.ActiveMonthYearID =@ActiveMonthYearId  AND CR_DAD.EstateID =@EstateID 
		GROUP BY CR_DAD.GangMasterID,DistbDate,C_GM .GangName 
) A
LEFT JOIN

(
SELECT DISTINCT CR_DAD1.GangMasterID,C_GM .GangName  ,CR_DAD1.DistbDate ,CR_DAD1.TotalHK ,CR_DAD1.TotalOT
	   FROM Checkroll.DailyActivityDistribution CR_DAD1
	   INNER JOIN Checkroll .GangMaster C_GM ON C_GM .GangMasterID =CR_DAD1 .GangMasterID 
	   WHERE CR_DAD1.GangMasterID IS NOT NULL AND CR_DAD1.ActiveMonthYearID =@ActiveMonthYearId  AND CR_DAD1.EstateID =@EstateID 
	
)B ON A.GangMasterID =B .GangMasterID AND A.DistbDate =B .DistbDate 
WHERE A.ADMandays <> B.TotalHK  OR A.ADOT <> B.TotalOT 



UNION ALL

  SELECT 
  C.GangName ,C.GangMasterID ,C .RDate  ,C.HK   As TotalHK, 0 As DistributedHK ,C.OT  As TotalOT,0 As DistributedOT 
   FROM 
(
SELECT   GangName , GangMasterID ,C_DA.RDate ,ISNULL(SUM(C_AS .TimesBasic),0) AS HK,ISNULL(SUM(C_DA .TotalOT),0) AS OT   FROM Checkroll .DailyAttendance  C_DA
INNER JOIN Checkroll .DailyTeamActivity  C_DT on C_DA .DailyTeamActivityID =C_DT.DailyTeamActivityID 
INNER JOIN Checkroll .AttendanceSetup C_AS ON C_AS .AttendanceSetupID =C_DA .AttendanceSetupID
AND (C_AS .AttendanceCode IN ('11','51','J1')) 
WHERE C_DT.Activity ='LAIN' AND  GangMasterID IS NOT NULL AND C_DA .ActiveMonthYearID =@ActiveMonthYearId  AND C_DA.EstateID =@EstateID 

GROUP BY GangMasterID ,GangName ,RDate 
HAVING (ISNULL(SUM(C_AS .TimesBasic),0) >0  OR ISNULL(SUM(C_DA .TotalOT),0)>0)
)C


LEFT JOIN 
(
SELECT  DISTINCT GangMasterID ,DistbDate  FROM Checkroll  .DailyActivityDistribution WHERE GangMasterID IS NOT NULL
 AND ActiveMonthYearID =@ActiveMonthYearId  AND EstateID =@EstateID 
) D on C.GangMasterID =D .GangMasterID and C.RDate = D.DistbDate 
WHERE D.GangMasterID is null and D.DistbDate IS NULL  

UNION ALL


  SELECT 
  AC .GangName ,AC.GangMasterID ,AC .RDate  ,0  As TotalHK, 0 As DistributedHK ,AC.OT  As TotalOT,0 As DistributedOT 
   FROM 
(
SELECT   GangName , GangMasterID ,C_DA.RDate ,0 AS HK,ISNULL(SUM(C_DA .TotalOT),0) AS OT   FROM Checkroll .DailyAttendance  C_DA
INNER JOIN Checkroll .DailyTeamActivity  C_DT on C_DA .DailyTeamActivityID =C_DT.DailyTeamActivityID 
INNER JOIN Checkroll .AttendanceSetup C_AS ON C_AS .AttendanceSetupID =C_DA .AttendanceSetupID
AND (C_AS .AttendanceCode NOT IN ('11','51','J1')) 
WHERE C_DT.Activity ='LAIN' AND  GangMasterID IS NOT NULL AND C_DA .ActiveMonthYearID =@ActiveMonthYearId  AND C_DA.EstateID =@EstateID 

GROUP BY GangMasterID ,GangName ,RDate 
HAVING (ISNULL(SUM(C_DA .TotalOT),0)>0)
)AC


LEFT JOIN 
(
SELECT  DISTINCT GangMasterID ,DistbDate  FROM Checkroll  .DailyActivityDistribution WHERE GangMasterID IS NOT NULL
 AND ActiveMonthYearID =@ActiveMonthYearId  AND EstateID =@EstateID 
) D on AC.GangMasterID =D .GangMasterID and AC.RDate = D.DistbDate 
WHERE D.GangMasterID is null and D.DistbDate IS NULL  

UNION ALL

SELECT GangName,GangMasterID,C_DA.RDate ,ISNULL(SUM(C_AS .TimesBasic),0) As TotalHK,0 As DistributedHK 
,ISNULL(SUM(C_DA .TotalOT),0) As TotalOT ,0 As DistributedOT 
 FROM 
Checkroll.DailyAttendance AS C_DA
INNER JOIN Checkroll.DailyTeamActivity AS C_DTA ON C_DA.DailyTeamActivityID = C_DTA.DailyTeamActivityID
INNER JOIN Checkroll .AttendanceSetup C_AS ON C_AS .AttendanceSetupID =C_DA .AttendanceSetupID 
WHERE GangMasterID NOT IN (SELECT DAD.GangMasterID    FROM Checkroll .DailyActivityDistribution DAD 
WHERE DAD .GangMasterID IS NOT NULL AND ActiveMonthYearID =@ActiveMonthYearId  AND EstateID =@EstateID  )
--08-12-2011 AND Activity ='LAIN'
AND Activity ='LAIN'  AND ActiveMonthYearID =@ActiveMonthYearId  AND C_DA.EstateID =@EstateID 
GROUP BY GangMasterID ,GangName ,RDate 
HAVING (ISNULL(SUM(C_AS .TimesBasic),0) > 0 AND ISNULL(SUM(C_DA .TotalOT),0) >0)
)R
--WHERE gangname ='xxxxxx'
-- ORDER BY GangMasterID ,DistbDate
