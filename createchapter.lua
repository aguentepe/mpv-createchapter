local utils = require("mp.utils")

local function create_chapter()
    local time_pos = mp.get_property_number("time-pos")
    local time_pos_osd = mp.get_property_osd("time-pos/full")
    local curr_chapter = mp.get_property_number("chapter")
    local chapter_count = mp.get_property_number("chapter-list/count")
    local all_chapters = mp.get_property_native("chapter-list")
    mp.osd_message(time_pos_osd, 1)

    if chapter_count == 0 then
        all_chapters[1] = {
            title = "chapter_1",
            time = time_pos
        }
        -- We just set it to zero here so when we add 1 later it ends up as 1
        -- otherwise it's probably "nil"
        curr_chapter = 0
        -- note that mpv will treat the beginning of the file as all_chapters[0] when using pageup/pagedown
        -- so we don't actually have to worry if the file doesn't start with a chapter
    else
        -- to insert a chapter we have to increase the index on all subsequent chapters
        -- otherwise we'll end up with duplicate chapter IDs which will confuse mpv
        -- +2 looks weird, but remember mpv indexes at 0 and lua indexes at 1
        -- adding two will turn "current chapter" from mpv notation into "next chapter" from lua's notation
        -- count down because these areas of memory overlap
        for i = chapter_count, curr_chapter + 2, -1 do
            all_chapters[i + 1] = all_chapters[i]
        end
        all_chapters[curr_chapter+2] = {
            title = "chapter_"..curr_chapter,
            time = time_pos
        }
    end
    mp.set_property_native("chapter-list", all_chapters)
    mp.set_property_number("chapter", curr_chapter+1)
end

local function write_chapter()
    local chapter_count = mp.get_property_number("chapter-list/count")
    local all_chapters = mp.get_property_native("chapter-list")
    local file_content = ";FFMETADATA1\n"
    local current_chapter = nil
    local previous_chapter = all_chapters[1]

    for i = 1, chapter_count, 1 do
        current_chapter = all_chapters[i]

        if i ~= 1 then
            local content_next_chapter="[CHAPTER]\nTIMEBASE=1/1000\nSTART="..string.format("%.f", previous_chapter.time*1000).."\nEND="..string.format("%.f", current_chapter.time*1000).."\ntitle="..current_chapter.title.."\n"
            file_content = file_content..content_next_chapter
        end
        if i == chapter_count then
            local content_last_chapter="[CHAPTER]\nTIMEBASE=1/1000\nSTART="..string.format("%.f", current_chapter.time*1000).."\nEND="..string.format("%.f", mp.get_property_number("duration")*1000).."\ntitle="..current_chapter.title.."\n"
            file_content = file_content..content_last_chapter
        end
        previous_chapter = current_chapter
    end

    local path = mp.get_property("path")
    dir, name_ext = utils.split_path(path)
    local name = string.sub(name_ext, 1, (string.len(name_ext)-4))
    local out_path = utils.join_path(dir, name.."_chapter.ffmd")
    local file = io.open(out_path, "w")
    if file == nil then
        dir = utils.getcwd()
        out_path = utils.join_path(dir, "create_chapter.ffmd")
        file = io.open(out_path, "w")
    end
    if file == nil then
        mp.error("Could not open chapter file for writing.")
        return
    end
    file:write(file_content)
    file:close()
    mp.osd_message("Export file to: "..out_path, 3)
end

mp.add_key_binding("C", "create_chapter", create_chapter, {repeatable=true})
mp.add_key_binding("X", "write_chapter", write_chapter, {repeatable=false})
