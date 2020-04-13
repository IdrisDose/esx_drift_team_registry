let types = [];

window.addEventListener("message", function (event) {
  if (event.data.type == "enableui") {
    document.body.style.display = event.data.enable ? "block" : "none";
  }

  $.post("http://esx_drift_team_registry/team/types", JSON.stringify({})).then(
    (resp) => {
      if (resp.status == "success") {
        resp.types.forEach((type) => {
          types.push({ text: type.type, value: type.id });
        });

        swapState("main");
      }
    }
  );
});

document.onkeyup = function (data) {
  if (data.which == 27) {
    // Escape key
    $.post("http://esx_drift_team_registry/escape", JSON.stringify({}));
  }
};

$("#drift_team_register").submit(function (event) {
  event.preventDefault(); // Prevent form from submitting

  $.post(
    "http://esx_drift_team_registry/team/register",
    JSON.stringify($("#drift_team_register").serializeArray())
  ).then((resp) => {
    if (resp.status == "success") {
      swapState("main");
    }
  });

  $("#drift_team_register").trigger("reset");
});

$("#drift_team_edit").submit(function (event) {
  event.preventDefault(); // Prevent form from submitting

  $.post(
    "http://esx_drift_team_registry/team/edit",
    JSON.stringify($("#drift_team_edit").serializeArray())
  ).then((resp) => {
    if (resp.status == "success") {
      swapState("main");
    }
  });

  $("#drift_team_edit").trigger("reset");
});

const colors = [
  "",
  "Red",
  "Green",
  "Yellow",
  "Blue",
  "L-Blue",
  "Purple",
  "White",
  "Dark Red",
  "Pink",
];

let teams = [];

const swapState = (newState) => {
  let title = "";
  let help = "";
  if (newState === "main") {
    $("#main-menu").show();
    $("#register-menu").hide();
    $("#edit-menu").hide();
    $("#view-menu").hide();

    $(".dialog").css("overflow-y", "hidden");
    title = "Welcome to the teams management menu!";
    help = "Please select an option below.";
  } else if (newState === "register") {
    $("#main-menu").hide();
    $("#register-menu").show();
    $("#edit-menu").hide();
    $("#view-menu").hide();
    title = "Enter the details as needed";
    help = "Fill out the needed fields.";
    populateTypes();
  } else if (newState === "view") {
    $("#main-menu").hide();
    $("#register-menu").hide();
    $("#edit-menu").hide();
    $("#view-menu").show();
    $(".dialog-inner").css("overflow-y", "auto");
    title = "View all teams";
    help = "Select an option.";
  } else if (newState === "edit") {
    $("#main-menu").hide();
    $("#register-menu").hide();
    $("#edit-menu").show();
    $("#view-menu").hide();
    title = "Edit Team";
    help = "Edit any details needed.";
    populateTypes();
  }

  $("#menu-header").html(title);
  $("#menu-title .help").html(help);
};

$("#btn-new-team").on("click", (event) => {
  event.preventDefault();
  swapState("register");
});

$("#btn-view-teams").on("click", (event) => {
  event.preventDefault();
  swapState("view");

  $.post("http://esx_drift_team_registry/teams", JSON.stringify({})).then(
    (resp) => {
      let { status, data } = resp;
      if (status == "success") {
        renderTeams(data);
      }
    }
  );
});

$(".back-btn").on("click", (event) => {
  event.preventDefault();
  swapState("main");
});

const deleteTeam = (event, teamid) => {
  event.preventDefault();
  $.post(
    "http://esx_drift_team_registry/team/delete",
    JSON.stringify({ teamid })
  ).then((resp) => {
    let { status, data } = resp;
    if (status == "success") {
      swapState("main");
    }
  });
};

const editTeam = (event, teamid) => {
  event.preventDefault();

  console.log(teamid);

  let team = teams.find((t) => t.id == teamid);

  $("#drift_team_edit [name='team_name']").val(team.name);
  $("#drift_team_edit [name='team_color']").val(team.color).trigger("change");
  $("#drift_team_edit [name='team_tag']").val(team.tag);
  $("#drift_team_edit [name='team_type']").val(team.type).trigger("change");
  $("#drift_team_edit [name='team_id']").val(team.id);

  swapState("edit");
};

const showTag = (event, teamid) => {
  $.post("http://esx_drift_team_registry/team/tag", JSON.stringify({ teamid }));
};

const renderTeams = (data) => {
  $("#team-list").children().remove();

  teams.length = 0;
  teams = data;

  //Fetch Teams
  let html = "";
  if (teams.length != 0) {
    teams.forEach((team) => {
      html += "<tr>";
      html += `<td>${team.id}</td>`;
      html += `<td>${team.name}</td>`;
      html += `<td>${team.tag}</td>`;
      html += `<td>${colors[team.color]}</td>`;
      html += `<td>${team.type}</td>`;
      html += "<td>";
      html += `<button onclick="showTag(event,${team.id})" style="margin-right:5px;">Show Tag</button>`;
      html += `<button onclick="editTeam(event,${team.id})" style="margin-right:5px;">Edit</button>`;
      html += `<button onclick="deleteTeam(event,${team.id})">Delete</button>`;
      html += "</td>";
      html += "</tr>";
    });
  } else {
    html += "<tr>";
    html += "<td colspan='6' style='text-align: center;'>NO TEAMS</td>";
    html += "</tr>";
  }

  $("#team-list").html(html);
};

const populateTypes = () => {
  let html = "";
  types.forEach((type) => {
    html += `<option value='${type.value}'>${type.text}</option>`;
  });

  $(".team_type").html(html);
};
