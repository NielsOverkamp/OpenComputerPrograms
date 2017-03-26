IPHeader = {}

function IPHeader:new(source, destination, content)
  ipHeader = {
    headerID = 1,
    source = source,
    nextHeader = content.headerID,
    destination = destination,
    content = content,
  }
  return ipHeader
end

return IPHeader
