<style>
    .section {
        background-color: #f1f1f1;
        background-image: none;
        border-top: 1px solid #999;
        font-size: .8em;
        padding: 1em;
    }
    .section-body.collapsed {
        display: none;
    }
    .collapsed .icon-caret-down {
        display: none;
    }
    .expanded .icon-caret-right {
        display: none;
    }
    .datatable {
        padding-top: 5px;
    }
    thead .table_cell {
        background-color: #ccc !important;
    }
    td.actions {
        padding: 3.4px !important;
        vertical-align: middle;
    }
    td.actions td {
        padding: 3.4px !important;
    }
    .form-name {
        display: inline;
        margin-right: 10px;
    }
    .dataTables_info {
        padding-top: 0.5em !important;
    }
    .dataTables_length {
        padding-top: 0.5em;
        padding-left: 1.5em;
    }
    tr:hover, td.highlight {
        background-color: whitesmoke !important;
    }
    input[type=button][disabled], input[type=button][disabled]:hover {
        background-color: lightgray;
        background-image: none;
        color: gray;
    }
    .actions .icon:before {
        content: "\f1234";
    }
    .actions .icon.icon-remove:before {
        content: "\e816";
    }
    .actions .icon.icon-edit:before {
        content: "\f14c";
    }
    .actions .icon.icon-view:before {
        content: "\e813";
    }
    .actions .icon.icon-reassign:before {
        content: "\e92f";
    }
    .actions .icon.icon-restore:before {
        content: "\e817";
    }
}
</style>

<table cellspacing="0" width="100%">
<tbody id="sections">
    <tr id="loading">
        <td>Loading...</td>
    </tr>
</tbody>
</table>

<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.16/css/jquery.dataTables.min.css"/>
<script type="text/JavaScript" language="JavaScript" src="https://cdn.datatables.net/1.10.16/js/jquery.dataTables.min.js"></script>
<script type="text/JavaScript" language="JavaScript" src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.11/handlebars.js"></script>
<script id="section-tmpl" type="text/x-handlebars-template">
    <tr class="section-header collapsed {{sectionStatus}}" style="{{sectionDisplay}};">
        <td class="section">
            <span class="icon icon-caret-down gray"></span>
            <span class="icon icon-caret-right gray"></span>
            <span>{{sectionName}}</span>
        </td>
    </tr>
    <tr class="section-body collapsed {{sectionStatus}}" data-study-event-oid="{{studyEventOid}}">
    <td>
    <div class="box_T">
    <div class="box_L">
    <div class="box_R">
    <div class="box_B">
    <div class="box_TL">
    <div class="box_TR">
    <div class="box_BL">
    <div class="box_BR">
    <div class="tablebox_center">
        <table border="0" cellpadding="0" cellspacing="0">
        <tbody>
        {{#each forms as |form|}}
        <tr>
            <td colspan="3" valign="top">
                <input type="button" class="add-new" value="Add New" data-form-oid="{{form.[@OID]}}" {{{form.disabled}}}>
                <h3 class="form-name">{{form.[@Name]}}</h3>
                <table border="0" cellpadding="0" cellspacing="0" class="datatable">
                <thead>
                    <tr valign="top">
                        {{#each form.itemGroups as |itemGroup|}}
                            {{#each itemGroup.items as |item|}}
                                <td class="table_cell">{{item.Question.TranslatedText}}</td>
                            {{/each}}
                        {{/each}}
                        <td class="table_cell">
                            <center>Status</center>
                        </td>
                        <td class="table_cell">
                            <center>Updated</center>
                        </td>
                        <td class="table_cell">
                            <center>Actions</center>
                        </td>
                    </tr>
                    <tr valign="top">
                        {{#each form.itemGroups as |itemGroup|}}
                            {{#each itemGroup.items as |item|}}
                                <td class="table_cell"></td>
                            {{/each}}
                        {{/each}}
                        <td class="table_cell">
                        </td>
                        <td class="table_cell">
                        </td>
                        <td class="table_cell">
                        </td>
                    </tr>
                </thead>
                <tbody>
                    {{#each form.submissions as |submission|}}
                        <tr class="submission {{submission.hideStatus}}" style="{{submission.display}}">
                            {{#each submission.data as |item|}}
                                <td class="table_cell">{{item}}</td>
                            {{/each}}
                            <td align="center" class="table_cell">{{submission.studyStatus}}</td>
                            <td align="center" class="table_cell"></td>
                            <td class="table_cell actions">
                                <table border="0" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr valign="top">
                                            {{#each submission.links as |link|}}
                                            <td>
                                                <a href="${pageContext.request.contextPath}{{link.[@href]}}">
                                                <span class="icon icon-{{link.[@rel]}}" border="0" alt="{{link.[@rel]}}" title="{{link.[@rel]}}" align="left" hspace="6">
                                                </span></a>
                                            </td>
                                            {{/each}}
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    {{/each}}
                </tbody>
                </table>
            {{/each}}
            </td>
        </tr>
        </tbody>
        </table>
        <br>
    </div>
    </div>
    </div>
    </div>
    </div>
    </div>
    </div>
    </div>
    </div>
    </td>
    </tr>
</script>

<script>
$(function() {
    function collection(x) {
        if (x)
            return x.length ? x : [x];
        return [];
    }
    $.get('rest/clinicaldata/json/view/${study.oid}/${studySub.oid}/*/*?showArchived=y', function(data) {
        var numCommons = 0;
        var numVisitBaseds = 0;

        var studyOid = data.ClinicalData['@StudyOID'];
        var studySubjectOid = data.ClinicalData.SubjectData['@SubjectKey'];

        var studyEvents = {};
        var forms = {};
        var itemGroups = {};
        var items = {};

        var metadata;
        for (var i=0, studies=collection(data.Study); i<studies.length; i++) {
            if (studies[i]['@OID'] === '${study.oid}') {
                metadata = studies[i].MetaDataVersion;
                break;
            }
        }        
        collection(metadata.ItemDef).forEach(function(item) {
            items[item['@OID']] = item;
        });
        collection(metadata.ItemGroupDef).forEach(function(itemGroup) {
            itemGroup.items = itemGroup.ItemRef.map(function(ref) {
                return items[ref['@ItemOID']];
            });
            itemGroups[itemGroup['@OID']] = itemGroup;
        });
        collection(metadata.FormDef).forEach(function(form) {
            form.itemGroups = {};
            form.submissionObj = {};
            collection(form.ItemGroupRef).forEach(function(ref) {
                var id = ref['@ItemGroupOID'];
                var itemGroup = itemGroups[id]
                form.itemGroups[id] = itemGroup;
                itemGroup.items.forEach(function(item) {
                    form.submissionObj[item['@OID']] = [];
                });
            });
            form.submissions = [];
            forms[form['@OID']] = form;
        });
        collection(metadata.StudyEventDef).forEach(function(studyEvent) {
            studyEvent.forms = collection(studyEvent.FormRef).filter(function(ref) {
                return ref['OpenClinica:ConfigurationParameters']['@HideCRF'] === 'No';
            }).map(function(ref) {
                var form = forms[ref['@FormOID']];
                form.studyEvent = studyEvent;
                form.disabled = '';
                return form;
            });
            studyEvents[studyEvent['@OID']] = studyEvent;
        });

        collection(data.ClinicalData.SubjectData.StudyEventData).forEach(function(studyEvent) {
            var formData = studyEvent.FormData;
            if (!formData)
                return;

            var form = forms[formData['@FormOID']];
            if (!form)
                return;

            if (form.studyEvent['@Repeating'] === 'No')
                form.disabled = 'disabled="disabled"';

            var links = [];
            $.merge(links, collection(studyEvent['OpenClinica:links']['OpenClinica:link']));
            $.merge(links, collection(formData['OpenClinica:links']['OpenClinica:link']));
            var order = ['edit', 'view', 'remove', 'restore', 'reassign'];
            links.sort(function(a, b) {
                return order.indexOf(a['@rel']) - order.indexOf(b['@rel']);
            });

            var hideStatus = formData['@OpenClinica:Status'] === 'invalid' ? 'oc-status-removed' : 'oc-status-active';
            var submission = {
                studyStatus: studyEvent['@OpenClinica:Status'],
                hideStatus: hideStatus,
                display: hideStatus === 'oc-status-removed' ? 'display:none;' : '',
                data: $.extend(true, {}, form.submissionObj),
                links: links
            };
            collection(formData.ItemGroupData).forEach(function(igd) {
                collection(igd.ItemData).forEach(function(item) {
                    submission.data[item['@ItemOID']].push(item['@Value']);
                });
            });
            form.submissions.push(submission);
        });

        $('#oc-status-hide').on('change', function() {
            $('tr.section-header, tr.section-body').removeClass('expanded').addClass('collapsed');
            var targets = $('tr.section-header, tr.submission');
            var hides = targets.filter('.' + $(this).val());
            hides.hide();
            targets.not(hides).show();
        });

        var hideStatus = $('#oc-status-hide').val();
        var sectionTable = $('#sections');
        var sectionTmpl = Handlebars.compile($('#section-tmpl').html());
        for (var studyEventId in studyEvents) {
            var studyEvent = studyEvents[studyEventId];
            if (studyEvent['@OpenClinica:EventType'] === 'Common') {
                var status = studyEvent['@OpenClinica:Status'] === 'AVAILABLE' ? 'oc-status-active' : 'oc-status-removed';
                var display = status === hideStatus ? 'display:none;' : '';
                sectionTable.append(sectionTmpl({
                    sectionName: studyEvent['@Name'],
                    sectionStatus: status,
                    sectionDisplay: display,
                    studyEventOid: studyEventId,
                    forms: studyEvent.forms
                }));
                numCommons++;
            }
            else {
                numVisitBaseds++;
            }
        }
        sectionTable.on('click', '.section-header', function() {
            $(this).next().addBack().toggleClass('collapsed expanded');
        });
        sectionTable.on('click', '.add-new', function() {
            var btn = $(this);
            var formOid = btn.data('form-oid');
            var studyEventOid = btn.closest('.section-body').data('study-event-oid');
            $.ajax({
                type: 'post',
                url: '${pageContext.request.contextPath}/pages/api/addAnotherForm',
                cache: false,
                data: {
                    studyoid: studyOid,
                    studyeventdefinitionoid: studyEventOid,
                    studysubjectoid: studySubjectOid,
                    crfoid: formOid
                },
                success: function(obj) {
                    window.location.href = '${pageContext.request.contextPath}' + obj.url;
                },
                error: function(e) {
                    alert('Error. See console log.');
                    console.log(e);
                }
            });
        });

        if (!numCommons) {
            $('#commonEvents').hide();
            $('#commonEvents_collapser').hide();
        }
        if (!numVisitBaseds) {
            $('#subjectEvents').hide();
            $('#excl_subjectEvents_open').hide();
            $('#excl_subjectEvents_close').hide();
        }

        var datatables = $('table.datatable');
        datatables.each(function() {
            var table = $(this).DataTable({
                dom: "frtilp",
                language: {
                    paginate: {
                        first: '<<',
                        previous: '<',
                        next: '>',
                        last: '>>'
                    }
                },
                columnDefs: [{
                    targets: -1,
                    render: function(data, type, row) {
                        return data;
                    }
                }, {
                    targets: '_all',
                    render: function(data, type, row) {
                        return data.length > 200 ?
                            data.substr(0, 200) +'…' : data;
                    }
                }],
                initComplete: function () {
                    var columns = this.api().columns();
                    columns.every(function() {
                        var column = this;
                        if (column.index() === columns.indexes().length - 1)
                            return;
                        var select = $('<select><option value=""></option></select>')
                            .prependTo($(column.header()))
                            .on('change', function () {
                                var val = $.fn.dataTable.util.escapeRegex(
                                    $(this).val()
                                );
                                column
                                    .search( val ? '^' + val + '$' : '', true, false )
                                    .draw();
                            });
                        column.data().unique().sort().each(function(val, index, api) {
                            select.append('<option value="' + val + '">' + val + '</option>');
                        });
                    });
                }
            });
            $(this).children('tbody').on('mouseenter', 'td.table_cell', function () {
                var colIdx = table.cell(this).index().column; 
                $(table.cells().nodes()).removeClass('highlight');
                $(table.column(colIdx).nodes()).addClass('highlight');
            });
        });
        datatables.each(function() {
            var theTable = $(this);
            var header = theTable.parent();
            var paging = theTable.next();
            var pagesize = paging.next().children().contents();
            header.prevUntil().prependTo(header);
            paging.text(paging.text().replace(' to ', '-').replace('entries', 'rows'));
            pagesize[2].replaceWith(' rows per page');
            pagesize[0].remove();
        });
        datatables.parent().css({
            'max-width': $(window).width() - 200 + 'px',
            'overflow': 'scroll'
        });        

        $('#loading').remove();
    });
});
</script>
