-- 10.1.37-MariaDB

CREATE OR REPLACE DATABASE db_komunaliniai;

USE db_komunaliniai;

-- Ši lentelė turi daug stulpelių, tačiau tai nėra trūkumas, nes lentelė yra normalizuota.
CREATE TABLE atsiskaitymas (
    -- Aušrinė
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    apskaitos_data DATE NOT NULL,
    atsiskaitymo_data DATE NOT NULL,
    isiskolinimas_permoka decimal(5,2) NOT NULL,
    vandens_pasild_tarif decimal(5,2) NOT NULL,
    vandens_pasild decimal(5,2) NOT NULL,
    silumos_kiekis_su_nepaskirstytu_KV_kiekiu_tarif decimal(5,2) NOT NULL,
    silumos_kiekis_su_nepaskirstytu_KV_kiekiu decimal(5,2) NOT NULL,
    kompensacija decimal(5,2) NOT NULL,
    temp_palaikymas decimal(5,2) NOT NULL,
    atlyginimai_tarif decimal(5,2) NOT NULL,
    atlyginimai decimal(5,2) NOT NULL,
    liftu_elektra_tarif decimal(5,2) NOT NULL,
    liftu_elektra decimal(5,2) NOT NULL,
    liftu_eksplotacija_tarif decimal(5,2) NOT NULL,
    liftu_eksplotacija decimal(5,2) NOT NULL,
    bendras_apsvietimas_tarif decimal(5,2) NOT NULL,
    bendras_apsvietimas decimal(5,2) NOT NULL,
    silumos_ukis_tarif decimal(5,2) NOT NULL,
    silumos_ukis decimal(5,2) NOT NULL,
    eksploatacija_tarif decimal(5,2) NOT NULL,
    eksploatacija decimal(5,2) NOT NULL,
    kaupiamosios_lesos_tarif decimal(5,2) NOT NULL,
    kaupiamosios_lesos decimal(5,2) NOT NULL,
    teritorijos_prieziura_tarif decimal(5,2) NOT NULL,
    teritorijos_prieziura decimal(5,2) NOT NULL,
    zemes_mokestis_tarif decimal(5,2) NOT NULL,
    zemes_mokestis decimal(5,2) NOT NULL,
    kasos_patarnavimai decimal(5,2) NOT NULL,

    -- Klaipėdos vandenys
    vanduo_kiekis tinyint UNSIGNED NOT NULL,
    vanduo_suma decimal(5,2) NOT NULL,
    nuotekos_kiekis tinyint UNSIGNED NOT NULL,
    nuotekos_suma decimal(5,2) NOT NULL,
    saltas_vanduo_pasildymui_kiekis tinyint UNSIGNED NOT NULL,
    saltas_vanduo_pasildymui_suma decimal(5,2) NOT NULL,
    nuotekos_po_salto_vandens_pasildymo_kiekis tinyint UNSIGNED NOT NULL,
    nuotekos_po_salto_vandens_pasildymo_suma decimal(5,2) NOT NULL,
    apskaitos_veikla decimal(5,2) NOT NULL,
    ats_karsto_v_apsk_priet_aptarn_mokestis decimal(5,2) NOT NULL,

    -- Dujos
    dujos_nuo smallint UNSIGNED NOT NULL,
    dujos_iki smallint UNSIGNED NOT NULL,
    duju_tarifas decimal(5,2) NOT NULL,
    duju_pastovioji_tarifo_dalis_menesiui decimal(5,2) NOT NULL,

    -- Elektra
    elektra_nuo smallint UNSIGNED NOT NULL,
    elektra_iki smallint UNSIGNED NOT NULL,
    elektros_tarifas decimal(5,2) NOT NULL,

    -- Sildymas
    sildymo_ismatuota_mokejimo_dalis decimal(5,2) NOT NULL,
    sildymo_nustatyta_mokejimo_dalis decimal(5,2) NOT NULL,
    sildymo_apskaitos_mokesciai decimal(5,2) NOT NULL,

    -- Šeimininko kompensacija už komunalinius arba nemėnesiniai mokėsčiai (pvz., už šiukšles)
    kita decimal(5,2)
);

CREATE TABLE kambarys (
    -- Id sutampa su apskaitoje nurodytu 'Prietaiso nr.'
    id char(8) NOT NULL PRIMARY KEY,
    pavadinimas char(50) NOT NULL
);

-- Apskaitos laikotarpiui apskaičiuota šiluma kambariui
CREATE TABLE kambario_sildymas (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    kambarys_id int NOT NULL,
    apskaita_id int NOT NULL,
    sildymo_rodmenys decimal(9,6) NOT NULL
);

-- Viename kambaryje gali gyventi keli gyventojai, kurie dalinasi mokesčiais už kambario šildymą
CREATE TABLE kambario_gyventojai (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    gyventojas_id int NOT NULL,
    kambarys_id int NOT NULL
);

CREATE TABLE gyventojas (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vardas char(50)
);

CREATE TABLE isvykimas (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    gyventojas_id int NOT NULL,
    -- Kompensacija už išvyka/mokesčių dalies pateikimas už svečius yra susietas su atskaitymu.
    atsiskaitymas_id int NOT NULL,
    data_nuo date NULL,
    data_iki date NULL,
    elektra_nuo smallint UNSIGNED NOT NULL,
    elektra_iki smallint UNSIGNED NOT NULL,
    -- Skaitliukai išvykimo atveju skaičiuojami tiksliai
    dujos_nuo decimal(6,3) NOT NULL,
    dujos_iki decimal(6,3) NOT NULL,
    vanduo_saltas_nuo decimal(6,3) NOT NULL,
    vanduo_karstas_iki decimal(6,3) NOT NULL,
    -- Jei TRUE, tai atitinkamam gyventojui reikės padengti ir svečio išlaidas
    svecias tinyint(1) NULL
);

CREATE TABLE atsiskaitymas_gyventojas (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    gyventojas_id INT NOT NULL,
    atsiskaitymas_id INT NOT NULL,
    -- Pagal susitarimą bendranuomininkas už tarifinius komunalinius gali mokėti mažiau
    vandens_koef decimal(2,2),
    duju_koef decimal(2,2),
    elektros_koef decimal(2,2),
    sildymo_koef decimal(2,2)
);

-- Išoriniai raktai
ALTER TABLE kambario_sildymas FOREIGN KEY kambarys_id REFERENCES kambarys(id);
ALTER TABLE kambario_sildymas FOREIGN KEY kambarys_id REFERENCES kambarys(id);
ALTER TABLE kambario_gyventojai FOREIGN KEY kambarys_id REFERENCES gyventojas(id);
ALTER TABLE kambario_gyventojai FOREIGN KEY gyventojas_id REFERENCES gyventojas(id);

-- Duomenų įvedimas
INSERT INTO atsiskaitymas SET
    apskaitos_data = '2018-01-01',
    atsiskaitymo_data = '2017-12-01',
    isiskolinimas_permoka = 0.01,
    vandens_pasild_tarif = 0.01,
    vandens_pasild = 0.01,
    silumos_kiekis_su_nepaskirstytu_KV_kiekiu_tarif = 0.01,
    silumos_kiekis_su_nepaskirstytu_KV_kiekiu = 0.01,
    kompensacija = 0.01,
    temp_palaikymas = 0.01,
    atlyginimai_tarif = 0.01,
    atlyginimai = 0.01,
    liftu_elektra_tarif = 0.01,
    liftu_elektra = 0.01,
    liftu_eksplotacija_tarif = 0.01,
    liftu_eksplotacija = 0.01,
    bendras_apsvietimas_tarif = 0.01,
    bendras_apsvietimas = 0.01,
    silumos_ukis_tarif = 0.01,
    silumos_ukis = 0.01,
    eksploatacija_tarif = 0.01,
    eksploatacija = 0.01,
    kaupiamosios_lesos_tarif = 0.01,
    kaupiamosios_lesos = 0.01,
    teritorijos_prieziura_tarif = 0.01,
    teritorijos_prieziura = 0.01,
    zemes_mokestis_tarif = 0.01,
    zemes_mokestis = 0.01,
    kasos_patarnavimai = 0.01,

    -- Klaipėdos vandenys
    vanduo_kiekis = 1,
    vanduo_suma = 0.01,
    nuotekos_kiekis = 1,
    nuotekos_suma = 0.01,
    saltas_vanduo_pasildymui_kiekis = 1,
    saltas_vanduo_pasildymui_suma = 0.01,
    nuotekos_po_salto_vandens_pasildymo_kiekis = 1,
    nuotekos_po_salto_vandens_pasildymo_suma = 0.01,
    apskaitos_veikla = 0.01,
    ats_karsto_v_apsk_priet_aptarn_mokestis = 0.01,

    -- Dujos
    dujos_nuo = 1,
    dujos_iki = 2,
    duju_tarifas = 0.01,
    duju_pastovioji_tarifo_dalis_menesiui = 0.01,

    -- Elektra
    elektra_nuo = 1,
    elektra_iki = 2,
    elektros_tarifas = 0.01,

    -- Sildymas
    sildymo_ismatuota_mokejimo_dalis = 0.01,
    sildymo_nustatyta_mokejimo_dalis = 0.01,
    sildymo_apskaitos_mokesciai = 0.01,

    -- Šeimininko kompensacija už komunalinius arba nemėnesiniai mokėsčiai (pvz., už šiukšles)
    kita = 100;
