function Today { echo "$(Year)-$(Month)-$(Day) | $(Hour)-$(Minute)-$(Second)"; }

function Year { echo "$(date +%Y)"; }
function Month { echo "$(date +%m)"; }
function Day { echo "$(date +%d)"; }

function Hour { echo "$(date +%H)"; }
function Minute { echo "$(date +%M)"; }
function Second { echo "$(date +%S)"; }
