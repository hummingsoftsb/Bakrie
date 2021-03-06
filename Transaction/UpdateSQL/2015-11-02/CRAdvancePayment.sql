
/****** Object:  StoredProcedure [Checkroll].[CRAdvancePaymentReport]    Script Date: 4/11/2015 2:47:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--==============================================================
--
-- Author     : Dadang Adi Hendradi
-- Modified By : SIVA SUBRAMANIAN S
-- Created on : Ahad, 20 Dec 2009, 16:37
--	Modified Date : 23/06/2010
-- Place      : Kuala Lumpur
-- For reporting - Advance Checkroll Report for (Month)
--
-- Modified   : Sabtu, 13 Feb 2010, 21:52
--              Now AdvancePaymentDet have filed :
--              - DedJamsostek
--              - DedOther
-- Modified   : Ahad, 14 Mar 2010, 01:30
--              - tambah AYear

-- Modified By : Kumar
--	Modified Date : 12/07/2010
-- Modified By : Stanley
--	Modified Date : 21/07/2011
-- Modified By : Stanley
--	Modified Date : 09/08/2011
--  Descp: Adding EstateID and ActiveMonthYearID
--==============================================================
ALTER PROCEDURE [Checkroll].[CRAdvancePaymentReport]
	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50)
AS

SELECT

	DISTINCT
	C_AP.ActiveMonthYearID, 
	C_AP.EstateID,
	CONVERT(DATETIME, C_AP.AdvProcessingDate) AS AdvProcessingDate,
	C_AP.AdvancePremium, 
	C_AP.Category,
	C_GM.GangName,		-- 09-08-2011
	C_EMP.Gender,
	C_EMP.EmpCode,
	C_EMP.EmpName,
	C_APD.Mandays,
	C_APD.Amount -- Advance
	--C_APD.Amount * (C_RSETUP.JHT / 100) AS Jamsostek,
	,C_APD.DedJamsostek
	,C_APD.DedOther
	,C_APD.PaidAmount
	,G_ESTATE.EstateName
	,G_AMY.AMonth
	,G_AMY.AYear
-- 09-08-2011	,C_DTA .GangName + '/' + C_DTA .Activity as Divisi
FROM 
	Checkroll.AdvancePayment AS C_AP
	INNER JOIN Checkroll.AdvancePaymentDet AS C_APD on C_AP.AdvancePaymentID = C_APD.AdvancePaymentID
	INNER JOIN Checkroll.CREmployee AS C_EMP ON C_APD.EmpID = C_EMP.EmpID
    INNER JOIN Checkroll.Salary as C_SAL on C_SAL.ActiveMonthYearID =@ActiveMonthYearID and C_EMP.EmpID = C_SAL.EmpID  
	LEFT JOIN Checkroll.GangMaster AS C_GM ON C_SAL.GangMasterID = C_GM.GangMasterID		-- 09-08-2011
	--INNER JOIN Checkroll.RateSetup AS C_RSETUP ON C_AP.Category = C_RSETUP.Category AND C_RSETUP.EstateID = C_AP.EstateID
	INNER JOIN General.Estate AS G_ESTATE ON C_AP.EstateID = G_ESTATE.EstateID
	INNER JOIN General.ActiveMonthYear AS G_AMY ON C_AP.ActiveMonthYearID = G_AMY.ActiveMonthYearID
Where C_AP .EstateID =@EstateID 
	  AND C_AP .ActiveMonthYearID =@ActiveMonthYearID 


