# QuotePdf uses Prawn's built-in Helvetica; its text is Windows-1252 safe (amounts
# are written "Rs.", not ₹), so the internationalisation warning is noise.
Prawn::Fonts::AFM.hide_m17n_warning = true
