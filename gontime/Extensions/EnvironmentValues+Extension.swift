extension EnvironmentValues {
    var timeColumnWidth: CGFloat {
        get { self[TimeColumnWidthKey.self] }
        set { self[TimeColumnWidthKey.self] = newValue }
    }
}
