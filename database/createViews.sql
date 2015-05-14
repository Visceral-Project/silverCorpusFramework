CREATE VIEW `fullParticipantSegmentation_view` AS
    select 
        `s`.`PatientID` AS `PatientID`,
        `s`.`VolumeID` AS `VolumeID`,
        `v`.`Modality` AS `Modality`,
        `v`.`Bodyregion` AS `BodyRegion`,
        `s`.`StructureID` AS `StructureID`,
        `s`.`ParticipantID` AS `ParticipantID`,
        `s`.`Performance` AS `Performance`,
        `s`.`Filename` AS `Filename`,
        `st`.`Name` AS `structureName`
    from
        ((`participantSegmentation` `s`
        left join `volume` `v` ON (((`v`.`PatientID` = `s`.`PatientID`)
            and (`v`.`VolumeID` = `s`.`VolumeID`))))
        left join `structure` `st` ON ((`st`.`StructureID` = `s`.`StructureID`)));


CREATE VIEW `fullSilverCorpusSegmentation_view` AS
    select 
        `s`.`PatientID` AS `patientID`,
        `s`.`VolumeID` AS `volumeID`,
        `v`.`Modality` AS `modality`,
        `v`.`Bodyregion` AS `bodyRegion`,
        `s`.`StructureID` AS `StructureID`,
        `s`.`LabelFusionTypeID` AS `labelFusionTypeID`,
        `s`.`Filename` AS `filename`,
        `s`.`Performance` AS `Performance`,
        `st`.`Name` AS `structureName`
    from
        ((`silvercorpusSegmentation` `s`
        left join `volume` `v` ON (((`v`.`PatientID` = `s`.`PatientID`)
            and (`v`.`VolumeID` = `s`.`VolumeID`))))
        left join `structure` `st` ON ((`s`.`StructureID` = `st`.`StructureID`)));
