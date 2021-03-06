
GO
/****** Object:  StoredProcedure [Checkroll].[DailyTeamActivityAutoInsert]    Script Date: 02/02/2015 9:42:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [Checkroll].[DailyTeamActivityAutoInsert]
@EstateID nvarchar (50),
@EstateCode nvarchar (50),
@DDate date,	
@CreatedBy nvarchar(50)	
AS

Declare @DailyTeamActivityID nvarchar(50)
Declare @GangMasterID nvarchar (50)
Declare @GangName nvarchar (50)
Declare @Activity nvarchar (50)
Declare @MandoreID nvarchar (50)
Declare @KraniID nvarchar (50)
Declare @MandorBesarID nvarchar (50)

	declare @pPKEY nvarchar(50)
	Declare	@pTotRow Numeric(18,0) 
BEGIN 

	SET XACT_ABORT ON


	DECLARE CR_Team CURSOR FOR  
	SELECT        Checkroll.GangMaster.GangMasterID, Checkroll.GangMaster.GangName, Checkroll.GangMaster.Category AS Activity, Checkroll.GangMaster.MandoreID, 
                         Checkroll.GangMaster.KraniID, Checkroll.GangMasterBesar.GangMasterBesarID as MandorBesarID
FROM            Checkroll.GangMaster LEFT JOIN
                         Checkroll.GangMasterBesar ON Checkroll.GangMaster.GangMasterID = Checkroll.GangMasterBesar.GangMasterID
	WHERE Checkroll.GangMaster.EstateID = @EstateID 

		Open CR_Team

		FETCH NEXT FROM CR_Team
  		INTO @GangMasterID, @GangName,@Activity, @MandoreID, @KraniID, @MandorBesarID

		SELECT  @pTotRow = @@CURSOR_ROWS

		WHILE @@FETCH_STATUS = 0 
		BEGIN
		IF NOT EXISTS(SELECT GangMasterID from Checkroll.DailyTeamActivity 
			WHERE EstateID = @EstateID AND GangMasterID =@GangMasterID AND  DDate = @DDate)
			
		BEGIN
		
		
		 SELECT @DailyTeamActivityID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + 1) AS VARCHAR)
                FROM   Checkroll.DailyTeamActivity
                DECLARE @i INT = 2
                WHILE EXISTS
                (SELECT id
                FROM    Checkroll.DailyTeamActivity
                WHERE   DailyTeamActivityID = @DailyTeamActivityID
                )
                BEGIN
                        SELECT @DailyTeamActivityID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
                        FROM   Checkroll.DailyTeamActivity
                        SET @i = @i + 1
                END
			
		
			--SELECT @DailyTeamActivityID = @EstateCode + 'R' + CONVERT(NVARCHAR,(ISNULL(MAX(Id),0) + 1))
			--FROM Checkroll.DailyTeamActivity
			
			INSERT INTO Checkroll.DailyTeamActivity( 
			DDate,
			DailyTeamActivityID,
			GangMasterID,
			EstateID,
			GangName,
			Activity,
			MandoreID,
			KraniID,
			MandorPremi,
			KraniPremi,
			CreatedBy,
			CreatedOn,
			ModifiedBy,
			ModifiedOn,
			MandorBesarID)
			Values (
			@DDate,
			@DailyTeamActivityID,
			@GangMasterID,
			@EstateID,
			@GangName,
			@Activity,
			@MandoreID,
			@KraniID,
			Null,
			Null,
			@CreatedBy,
			Getdate(),
			@CreatedBy,
			Getdate(),
			@MandorBesarID)
		
		END	
			
		
		
		
			FETCH NEXT FROM CR_Team
  			INTO @GangMasterID, @GangName,@Activity, @MandoreID, @KraniID, @MandorBesarID

	  		
		END
			CLOSE CR_Team
			
		DEALLOCATE CR_Team	
		
SELECT        Checkroll.DailyTeamActivity.DailyTeamActivityID AS [Daily Team Activity ID], Checkroll.DailyTeamActivity.DDate AS Date, 
                         Checkroll.DailyTeamActivity.DailyTeamActivityID AS [Daily Team Activity ID], Checkroll.DailyTeamActivity.GangMasterID AS [Gang Master Id], 
                         Checkroll.DailyTeamActivity.EstateID AS [Estate Id], General.Estate.EstateCode AS [Estate Code], Checkroll.DailyTeamActivity.GangName AS [Gang Name], 
                         Checkroll.DailyTeamActivity.Activity, Checkroll.DailyTeamActivity.MandoreID AS [Mandore ID], Checkroll.CREmployee.EmpCode AS [Emp Code Mandor], 
                         Checkroll.CREmployee.EmpName AS Mandor, Checkroll.DailyTeamActivity.KraniID AS [Krani ID], CREmployee_1.EmpCode AS [Emp Code Krani], 
                         CREmployee_1.EmpName AS Krani, Checkroll.DailyTeamActivity.MandorBesarID AS [Mandor Besar ID], CREmployee_2.EmpCode AS [Emp Code Mandor Besar], 
                         CREmployee_2.EmpName AS [Mandor Besar]
FROM            Checkroll.DailyTeamActivity INNER JOIN
                         Checkroll.CREmployee ON Checkroll.DailyTeamActivity.MandoreID = Checkroll.CREmployee.EmpID INNER JOIN
                         Checkroll.CREmployee AS CREmployee_1 ON Checkroll.DailyTeamActivity.KraniID = CREmployee_1.EmpID INNER JOIN
                         General.Estate ON Checkroll.DailyTeamActivity.EstateID = General.Estate.EstateID LEFT OUTER JOIN
                         Checkroll.CREmployee AS CREmployee_2 ON Checkroll.DailyTeamActivity.MandorBesarID = CREmployee_2.EmpID
		WHERE Checkroll.DailyTeamActivity.EstateID  = @EstateID and  CONVERT(DATE,DDate)= @DDate
		
END		
	



















