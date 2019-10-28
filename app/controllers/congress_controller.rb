class CongressController < ApplicationController
  layout 'congress'
  LANGUAGES = {
      he: "Hebrew",
      en: "English",
      ru: "Russian",
      es: "Spanish",
      it: "Italian",
      de: "German",
      nl: "Dutch",
      fr: "French",
      pt: "Portuguese",
      tr: "Türkçe",
      pl: "Polish",
      ar: "Arabic",
      hu: "Hungarian",
      fi: "Finnish",
      lt: "Lithuanian",
      ja: "Japanese",
      bg: "Bulgarian",
      ka: "Georgian",
      no: "Norwegian",
      sv: "Swedish",
      hr: "Croatian",
      zh: "Chinese",
      fa: "Persian",
      ro: "Romanian",
      hi: "Hindi",
      ua: "Ukrainian",
      mk: "Macedonian",
      sl: "Slovenian",
      lv: "Latvian",
      sk: "Slovak",
      cs: "Czech",
      am: "Amharic",
  }

  def index
    @languages = LANGUAGES.sort
    render layout: nil
  end

  def new
    @accept = []
    params.keys.each do |lang|
      @accept << lang if LANGUAGES[lang.to_sym]
    end
    @languages_4 = !!params[:languages_4]
    @full_screen = !!params[:full_screen]

    if @languages_4
      render :three, layout: 'three'
      return
    end
  end
end
